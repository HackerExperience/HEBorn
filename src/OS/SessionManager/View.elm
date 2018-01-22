module OS.SessionManager.View exposing (..)

import Html exposing (..)
import Html.CssHelpers
import Dict
import Core.Error as Error
import OS.Resources as OsRes
import OS.SessionManager.Config exposing (..)
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Types exposing (..)
import OS.SessionManager.WindowManager.View as WM
import OS.SessionManager.WindowManager.Resources as WmRes
import OS.SessionManager.Dock.View as Dock
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers


osClass : List class -> Attribute msg
osClass =
    .class <| Html.CssHelpers.withNamespace OsRes.prefix


wmClass : List class -> Attribute msg
wmClass =
    .class <| Html.CssHelpers.withNamespace WmRes.prefix


view : Config msg -> Model -> Html msg
view config model =
    let
        id =
            getSessionID config
    in
        div
            [ osClass [ OsRes.Session ] ]
            [ viewWM config id model
            , viewDock config id model
            ]



-- internals


viewDock : Config msg -> ID -> Model -> Html msg
viewDock config id model =
    let
        config_ =
            dockConfig id config
    in
        Dock.view config_ model
            |> Html.map (DockMsg >> config.toMsg)


viewWM : Config msg -> ID -> Model -> Html msg
viewWM config id model =
    let
        config_ =
            wmConfig id config
    in
        case Dict.get id model.sessions of
            Just wm ->
                wm
                    |> WM.view config_

            Nothing ->
                div [ wmClass [ WmRes.Canvas ] ] []


getSessionID : Config msg -> ID
getSessionID config =
    case config.activeContext of
        Gateway ->
            config.activeServer
                |> Tuple.first
                |> Servers.toSessionId

        Endpoint ->
            let
                endpointSessionId =
                    config.activeServer
                        |> Tuple.second
                        |> Servers.getEndpointCId
                        |> Maybe.map Servers.toSessionId
            in
                case endpointSessionId of
                    Just endpointSessionId ->
                        endpointSessionId

                    Nothing ->
                        "U = {x}, ∄ x ⊂ U"
                            |> Error.neeiae
                            |> uncurry Native.Panic.crash
