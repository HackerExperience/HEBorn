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
        ( instance, cmd, dispatch ) =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    let
                        ( modelG, cmdG, dispatchG ) =
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

                        ( modelE, cmdE, dispatchE ) =
                            Apps.launch data_
                                { sessionId = parentSession
                                , windowId = id
                                , context = Endpoint
                                }
                                app

                        cmd =
                            Cmd.batch [ cmdG, cmdE ]

                        dispatch =
                            Dispatch.batch [ dispatchG, dispatchE ]

                        context =
                            data
                                |> Game.getGame
                                |> Game.getAccount
                                |> Account.getContext

                        model =
                            DoubleContext context modelG modelE
                    in
                        ( model, cmd, dispatch )

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
            Cmd.map (AppMsg Active id) cmd

        window =
            Window
                (initialPosition model)
                (Size 600 400)
                False
                app
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
