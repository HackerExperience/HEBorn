module OS.SessionManager.Launch exposing (openApp, openOrRestoreApp)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Game.Data as Game
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Context exposing (Context(..))
import Game.Storyline.Missions.Actions exposing (Action(GoApp))
import Game.Servers.Shared as Servers
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Launch as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.WindowManager.Messages as WM
import Apps.Apps as Apps
import Apps.Models as Apps


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


openApp :
    Game.Data
    -> Maybe Context
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Maybe Apps.AppParams
    -> Model
    -> UpdateResponse
openApp =
    helper WM.insert


openOrRestoreApp :
    Game.Data
    -> Maybe Context
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Maybe Apps.AppParams
    -> Model
    -> UpdateResponse
openOrRestoreApp =
    helper WM.resert


type alias Action =
    Game.Data
    -> Maybe Context
    -> String
    -> Maybe Servers.CId
    -> Apps.App
    -> Maybe Apps.AppParams
    -> WM.Model
    -> ( WM.Model, Cmd WM.Msg, Dispatch )


helper :
    Action
    -> Game.Data
    -> Maybe Context
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Maybe Apps.AppParams
    -> Model
    -> UpdateResponse
helper action data maybeContext id serverCId app maybeParams model0 =
    case get id model0 of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, cmd, dispatch ) =
                    action data maybeContext uuid serverCId app maybeParams wm

                cmd_ =
                    Cmd.map (WindowManagerMsg id) cmd

                model_ =
                    refresh id wm_ model

                dispatch_ =
                    Dispatch.batch
                        [ dispatch
                        , data
                            |> Game.getGame
                            |> Game.getAccount
                            |> Account.getContext
                            |> GoApp app
                            |> Storyline.ActionDone
                            |> Storyline.Missions
                            |> Dispatch.storyline
                        ]
            in
                ( model_, cmd_, dispatch_ )

        Nothing ->
            ( model0, Cmd.none, Dispatch.none )
