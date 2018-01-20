module OS.SessionManager.View exposing (..)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Dict
import OS.Resources as OsRes
import OS.SessionManager.Config exposing (..)
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



--CONFREFACT : Remove Game.Data after refact this area


view : Config msg -> Game.Data -> Model -> Html msg
view config game model =
    div
        [ osClass [ OsRes.Session ] ]
        [ viewWM config game model
        , viewDock config game model
        ]



-- internals


viewDock : Config msg -> Game.Data -> Model -> Html msg
viewDock config game model =
    let
        config_ =
            dockConfig config
    in
        Dock.view config_ game model
            |> Html.map (DockMsg >> config.toMsg)


viewWM : Config msg -> Game.Data -> Model -> Html msg
viewWM config data model =
    let
        id =
            toSessionID data

        config_ =
            wmConfig id config
    in
        case Dict.get id model.sessions of
            Just wm ->
                wm
                    |> WM.view config_ data

            Nothing ->
                div [ wmClass [ WmRes.Canvas ] ] []
