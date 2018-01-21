module OS.SessionManager.WindowManager.Launch exposing (resert, insert)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Shared as Servers
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import Apps.Apps as Apps
import Apps.Models as Apps
import Apps.Launch as Apps


fallbackContext : Config msg -> Maybe Context -> Context
fallbackContext config maybeContext =
    case maybeContext of
        Just context ->
            context

        Nothing ->
            config.activeContext


resert :
    Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> String
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
resert config maybeContext maybeParams id serverCId app model =
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
            insert config maybeContext maybeParams id serverCId app model


insert :
    Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
insert config maybeContext maybeParams id serverCId app model =
    let
        { windows, visible, parentSession } =
            model

        ( instance, cmd, dispatch ) =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    let
                        context =
                            fallbackContext config maybeContext

                        ( gatewayParams, endpointParams ) =
                            case context of
                                Gateway ->
                                    ( maybeParams, Nothing )

                                Endpoint ->
                                    ( Nothing, maybeParams )

                        gatewayConfig =
                            appsConfig (Just Gateway) id (One Gateway) config

                        endpointConfig =
                            appsConfig (Just Endpoint) id (One Endpoint) config

                        ( modelG, cmdG, dispatchG ) =
                            Apps.launch gatewayConfig
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                gatewayParams
                                app

                        ( modelE, cmdE, dispatchE ) =
                            Apps.launch endpointConfig
                                { sessionId = parentSession
                                , windowId = id
                                , context = Endpoint
                                }
                                endpointParams
                                app

                        cmd =
                            Cmd.batch [ cmdG, cmdE ]

                        dispatch =
                            Dispatch.batch [ dispatchG, dispatchE ]

                        model =
                            DoubleContext context modelG modelE
                    in
                        ( model, cmd, dispatch )

                Apps.ContextlessApp ->
                    let
                        config_ =
                            appsConfig (Just Gateway) id (One Gateway) config

                        ( model, cmd, dispatch ) =
                            Apps.launch config_
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                maybeParams
                                app
                    in
                        ( SingleContext model, cmd, dispatch )

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
