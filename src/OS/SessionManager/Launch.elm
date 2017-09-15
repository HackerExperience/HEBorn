module OS.SessionManager.Launch exposing (openApp, openOrRestoreApp)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Shared as Servers
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.WindowManager.Launch as WindowManager
import Apps.Apps as Apps


openApp :
    Game.Data
    -> ID
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
openApp data id serverID app ({ sessions } as model0) =
    case Dict.get id sessions of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, cmd, msg ) =
                    WindowManager.insert data uuid serverID app wm

                cmd_ =
                    Cmd.map WindowManagerMsg cmd

                sessions_ =
                    Dict.insert id wm_ sessions

                model_ =
                    { model | sessions = sessions_ }
            in
                ( model_, cmd_, msg )

        Nothing ->
            ( model0, Cmd.none, Dispatch.none )


openOrRestoreApp :
    Game.Data
    -> ID
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
openOrRestoreApp data id serverID app ({ sessions } as model0) =
    case Dict.get id sessions of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, cmd, msg ) =
                    WindowManager.resert data uuid serverID app wm

                cmd_ =
                    Cmd.map WindowManagerMsg cmd

                sessions_ =
                    Dict.insert id wm_ sessions

                model_ =
                    { model | sessions = sessions_ }
            in
                ( model_, cmd_, msg )

        Nothing ->
            ( model0, Cmd.none, Dispatch.none )
