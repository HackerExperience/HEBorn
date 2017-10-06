module OS.SessionManager.WindowManager.Launch exposing (resert, insert)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types exposing (Context(..))
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import OS.SessionManager.WindowManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Models exposing (..)
import Apps.Apps as Apps
import Apps.Models as Apps
import Apps.Launch as Apps


resert :
    Game.Data
    -> String
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
resert data id serverID app ({ visible, hidden, windows } as model) =
    let
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
            insert data id serverID app model


insert :
    Game.Data
    -> ID
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
insert data id serverID app ({ windows, visible, parentSession } as model) =
    let
        contexts =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    data
                        |> Game.getGame
                        |> Game.getAccount
                        |> Account.getContext
                        |> Just

                Apps.ContextlessApp ->
                    Nothing

        ( instance, cmd, dispatch ) =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    let
                        ( model1, cmd1, dispatch1 ) =
                            Apps.launch data
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                app

                        data_ =
                            data
                                |> Game.getGame
                                |> Game.fromEndpoint
                                |> Maybe.withDefault data

                        ( model2, cmd2, dispatch2 ) =
                            Apps.launch data_
                                { sessionId = parentSession
                                , windowId = id
                                , context = Endpoint
                                }
                                app

                        cmd =
                            Cmd.batch [ cmd1, cmd2 ]

                        dispatch =
                            Dispatch.batch [ dispatch1, dispatch2 ]

                        model3 =
                            case contexts of
                                Just Gateway ->
                                    DoubleContext model1 model2

                                _ ->
                                    DoubleContext model2 model1
                    in
                        ( model3, cmd, dispatch )

                Apps.ContextlessApp ->
                    let
                        ( model, cmd, dispatch ) =
                            Apps.launch data
                                { sessionId = parentSession
                                , windowId = id
                                , context = Gateway
                                }
                                app
                    in
                        ( SingleContext model, cmd, dispatch )

        cmd_ =
            Cmd.map (WindowMsg id) cmd

        window =
            Window
                (initialPosition model)
                (Size 600 400)
                False
                app
                contexts
                instance
                False
                serverID

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
