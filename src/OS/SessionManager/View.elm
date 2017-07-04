module OS.SessionManager.View exposing (..)

import Html exposing (..)
import Html.CssHelpers
import Game.Models as Game
import Game.Data as Game
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
    .class <| Html.CssHelpers.withNamespace "os"


view : Game.Model -> Model -> Html Msg
view game model =
    div
        [ osClass [ OsCss.Session ] ]
        [ viewWM game model
        , viewDock game model
        ]



-- internals


viewDock : Game.Model -> Model -> Html Msg
viewDock game model =
    model
        |> Dock.view game
        |> Html.map DockMsg


viewWM : Game.Model -> Model -> Html Msg
viewWM game model =
    case (Game.toContext game) of
        Just data ->
            model
                |> windows
                |> List.filterMap (maybeViewWindow data model)
                |> div [ wmClass [ WmCss.Canvas ] ]

        Nothing ->
            Html.div [] []


maybeViewWindow :
    Game.Data
    -> Model
    -> WindowRef
    -> Maybe (Html Msg)
maybeViewWindow data model ( wmID, id ) =
    case getWindowManager wmID model of
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
