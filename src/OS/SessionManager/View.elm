module OS.SessionManager.View exposing (..)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as GameData
import Dict
import OS.Resources as OsRes
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.WindowManager.View as WM
import OS.SessionManager.WindowManager.Resources as WmRes
import OS.SessionManager.Dock.View as Dock


osClass : List class -> Attribute msg
osClass =
    .class <| Html.CssHelpers.withNamespace OsRes.prefix


wmClass : List class -> Attribute msg
wmClass =
    .class <| Html.CssHelpers.withNamespace WmRes.prefix


view : GameData.Data -> Model -> Html Msg
view game model =
    div
        [ osClass [ OsRes.Session ] ]
        [ viewWM game model
        , viewDock game model
        ]



-- internals


viewDock : GameData.Data -> Model -> Html Msg
viewDock game model =
    model
        |> Dock.view game
        |> Html.map DockMsg


viewWM : GameData.Data -> Model -> Html Msg
viewWM data model =
    let
        id =
            toSessionID data
    in
        case Dict.get id model.sessions of
            Just wm ->
                wm
                    |> WM.view data
                    |> Html.map WindowManagerMsg

            Nothing ->
                div [ wmClass [ WmRes.Canvas ] ] []
