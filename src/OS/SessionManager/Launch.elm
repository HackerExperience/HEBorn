module OS.SessionManager.Launch exposing (openApp, openOrRestoreApp)

import Dict
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Account.Models as Account
import Game.Storyline.Missions.Actions exposing (Action(GoApp))
import Game.Servers.Shared as Servers
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Launch as WindowManager
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Messages as WindowManager
import Apps.Apps as Apps


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


openApp :
    Game.Data
    -> ID
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> UpdateResponse
openApp =
    helper WindowManager.insert


openOrRestoreApp :
    Game.Data
    -> ID
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> UpdateResponse
openOrRestoreApp =
    helper WindowManager.resert


type alias Action =
    Game.Data
    -> String
    -> Maybe Servers.ID
    -> Apps.App
    -> WindowManager.Model
    -> ( WindowManager.Model, Cmd WindowManager.Msg, Dispatch )


helper :
    Action
    -> Game.Data
    -> ID
    -> Maybe Servers.ID
    -> Apps.App
    -> Model
    -> UpdateResponse
helper action data id serverID app model0 =
    case get id model0 of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, cmd, dispatch ) =
                    action data uuid serverID app wm

                cmd_ =
                    Cmd.map (WindowManagerMsg id) cmd

                model_ =
                    refresh id wm_ model

                dispatch_ =
                    Dispatch.batch
                        [ dispatch
                        , data.game.account
                            |> Account.getContext
                            |> GoApp app
                            |> Dispatch.missionAction data
                        ]
            in
                ( model_, cmd_, dispatch_ )

        Nothing ->
            ( model0, Cmd.none, Dispatch.none )
