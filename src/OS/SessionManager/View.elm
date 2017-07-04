module OS.SessionManager.View exposing (..)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as GameData
import OS.Style as OsCss
import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.WindowManager.View as WindowManager
import OS.SessionManager.WindowManager.Models as WindowManager
import OS.SessionManager.WindowManager.Style as WmCss
import OS.SessionManager.Dock.View as Dock


osClass : List class -> Attribute msg
osClass =
    .class <| Html.CssHelpers.withNamespace "os"


wmClass : List class -> Attribute msg
wmClass =
    .class <| Html.CssHelpers.withNamespace "wm"


view : GameData.Data -> Model -> Html Msg
view game model =
    div
        [ osClass [ OsCss.Session ] ]
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
    model
        |> windows data.id
        |> List.filterMap (maybeViewWindow data model)
        |> div [ wmClass [ WmCss.Canvas ] ]


maybeViewWindow :
    GameData.Data
    -> Model
    -> WindowRef
    -> Maybe (Html Msg)
maybeViewWindow data model ( wmID, id ) =
    case get wmID model of
        Just wm ->
            model
                |> getWindow ( wmID, id )
                |> Maybe.andThen
                    (\window ->
                        case window.state of
                            WindowManager.NormalState ->
                                wm
                                    |> WindowManager.view id data
                                    |> Html.map WindowManagerMsg
                                    |> Just

                            _ ->
                                Nothing
                    )

        Nothing ->
            Nothing
