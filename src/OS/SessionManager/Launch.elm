module OS.SessionManager.Launch exposing (openApp, openOrRestoreApp)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Storyline as Storyline
import Utils.React as React exposing (React)
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Context exposing (Context(..))
import Game.Storyline.Missions.Actions exposing (Action(GoApp))
import Game.Servers.Shared as Servers
import OS.SessionManager.Config exposing (..)
import OS.SessionManager.WindowManager.Config as WM
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.Launch as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.WindowManager.Messages as WM
import Apps.Apps as Apps


type alias UpdateResponse msg =
    ( Model, React msg )


openApp :
    WM.Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> UpdateResponse msg
openApp =
    helper WM.insert


openOrRestoreApp :
    WM.Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> UpdateResponse msg
openOrRestoreApp =
    helper WM.resert


type alias Action msg =
    WM.Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> String
    -> Maybe Servers.CId
    -> Apps.App
    -> WM.Model
    -> ( WM.Model, React msg )


helper :
    Action msg
    -> WM.Config msg
    -> Maybe Context
    -> Maybe Apps.AppParams
    -> ID
    -> Maybe Servers.CId
    -> Apps.App
    -> Model
    -> UpdateResponse msg
helper action config maybeContext maybeParams id serverCId app model0 =
    case get id model0 of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, react ) =
                    action config
                        maybeContext
                        maybeParams
                        uuid
                        serverCId
                        app
                        wm

                model_ =
                    refresh id wm_ model

                --dispatch_ =
                --    Dispatch.batch
                --        [ dispatch
                --        , data
                --            |> Game.getGame
                --            |> Game.getAccount
                --            |> Account.getContext
                --            |> GoApp app
                --            |> Storyline.ActionDone
                --            |> Storyline.Missions
                --            |> Dispatch.storyline
                --        ]
            in
                ( model_, react )

        Nothing ->
            ( model0, React.none )
