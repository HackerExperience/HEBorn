module OS.SessionManager.WindowManager.Launch exposing (resert, insert)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Shared as Servers
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import Apps.Apps as Apps
import Apps.Models as Apps
import Apps.Launch as Apps


fallbackContext : Game.Data -> Maybe Context -> Context
fallbackContext data maybeContext =
    case maybeContext of
        Just context ->
            context

        Nothing ->
            data
                |> Game.getGame
                |> Game.getAccount
                |> Account.getContext


resert :
    Game.Data
    -> Maybe Context
    -> String
    -> Maybe Servers.CId
    -> Apps.App
    -> Maybe Apps.AppParams
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
resert data maybeContext id serverCId app maybeParams model =
    -- TODO: maybe check if the opened window has the current endpoint, focus
    -- it if this is the case
    let
        { visible, hidden, windows } =
            model

        noVisible =
            visible
                |> List.filter (filterApp app windows)
                |> List.isEmpty

        noHidden =
            hidden
                |> List.filter (filterApp app windows)
                |> List.isEmpty

        noOpened =
            noVisible && noHidden
    in
        if noVisible && (not noHidden) then
            let
                model_ =
                    hidden
                        |> List.filter (filterApp app windows)
                        |> List.foldl restore model
            in
                ( model_, Cmd.none, Dispatch.none )
        else
            insert data maybeContext id serverCId app maybeParams model


insert :
    Game.Data
    -> Maybe Context
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Maybe Apps.AppParams
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
insert data maybeContext id serverCId app maybeParams model =
    let
        { windows, visible, parentSession } =
            model

        ( instance, cmd, dispatch ) =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    let
                        context =
                            fallbackContext data maybeContext

                        data_ =
                            data
                                |> Game.getGame
                                |> Game.fromEndpoint
                                |> Maybe.withDefault data

                        ( modelG, cmdG, dispatchG ) =
                            Apps.launch data
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                app

                        ( modelE, cmdE, dispatchE ) =
                            Apps.launch data_
                                { sessionId = parentSession
                                , windowId = id
                                , context = Endpoint
                                }
                                app

                        ( modelG_, modelE_ ) =
                            case maybeParams of
                                Just params ->
                                    case context of
                                        Gateway ->
                                            modelG
                                                |> Apps.launchParams True
                                                    params
                                                |> Tuple.second
                                                |> flip (,) modelE

                                        Endpoint ->
                                            modelE
                                                |> Apps.launchParams True
                                                    params
                                                |> Tuple.second
                                                |> (,) modelG

                                Nothing ->
                                    ( modelG, modelE )

                        cmd =
                            Cmd.batch [ cmdG, cmdE ]

                        dispatch =
                            Dispatch.batch [ dispatchG, dispatchE ]

                        model =
                            DoubleContext context modelG_ modelE_
                    in
                        ( model, cmd, dispatch )

                Apps.ContextlessApp ->
                    let
                        contextGateway =
                            { sessionId = parentSession
                            , windowId = id
                            , context = Gateway
                            }

                        ( model, cmd, dispatch ) =
                            Apps.launch data contextGateway app

                        model_ =
                            case maybeParams of
                                Just params ->
                                    model
                                        |> Apps.launchParams True params
                                        |> Tuple.second

                                Nothing ->
                                    model
                    in
                        ( SingleContext model_, cmd, dispatch )

        cmd_ =
            Cmd.map (AppMsg Active id) cmd

        window =
            Window
                (initialPosition model)
                (uncurry Size <| Apps.windowInitSize app)
                False
                app
                instance
                False
                serverCId

        windows_ =
            Dict.insert id window windows

        visible_ =
            moveTail id visible

        model_ =
            { model
                | windows = windows_
                , visible = visible_
                , focusing = Just id
            }
    in
        ( model_, cmd_, dispatch )
