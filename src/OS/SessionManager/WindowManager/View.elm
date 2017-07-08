module OS.SessionManager.WindowManager.View exposing (view)

import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import Html exposing (..)
import Game.Data as Game
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick, onMouseDown)
import Html.CssHelpers
import Html.Attributes exposing (attribute)
import Css exposing (left, top, asPairs, px, height, width, int, zIndex)
import Draggable
import Dict
import OS.SessionManager.WindowManager.Context as Context
import OS.SessionManager.WindowManager.Resources as Res
import Apps.Models as Apps
import Apps.View as Apps


{ id, class, classList } =
    Html.CssHelpers.withNamespace Res.prefix


view : Game.Data -> Model -> Html Msg
view data ({ windows, visible } as model) =
    let
        mapper id =
            case Dict.get id windows of
                Just window ->
                    window
                        |> getAppModelFromWindow
                        |> Apps.view data
                        |> Html.map (WindowMsg id)
                        |> windowWrapper id window
                        |> Just

                Nothing ->
                    Nothing
    in
        div [] (List.filterMap mapper visible)


styles : List Css.Style -> Attribute Msg
styles =
    Css.asPairs >> style


windowClasses : Window -> Attribute Msg
windowClasses window =
    if (window.maximized) then
        class
            [ Res.Window
            , Res.Maximizeme
            ]
    else
        class [ Res.Window ]


windowWrapper : ID -> Window -> Html Msg -> Html Msg
windowWrapper id window view =
    div
        [ windowClasses window
        , windowStyle window
        , onMouseDown (UpdateFocusTo (Just id))
        ]
        [ header id window
        , div
            [ class [ Res.WindowBody ] ]
            [ view ]
        ]


header : ID -> Window -> Html Msg
header id window =
    div
        [ Draggable.mouseTrigger id DragMsg ]
        [ div
            [ class [ Res.WindowHeader ]
            , onMouseDown (UpdateFocusTo (Just id))
            ]
            [ headerTitle (title window) (Apps.icon window.app)
            , headerContext id window.context
            , headerButtons id
            ]
        ]


headerContext : ID -> Context.Context -> Html Msg
headerContext id context =
    div []
        [ span
            [ class [ Res.HeaderContextSw ]
            , onClick (SwitchContext id)
            ]
            [ text (Context.toString context)
            ]
        ]


headerTitle : String -> String -> Html Msg
headerTitle title icon =
    div
        [ class [ Res.HeaderTitle ]
        , attribute "data-icon" icon
        ]
        [ text title ]


headerButtons : ID -> Html Msg
headerButtons id =
    div [ class [ Res.HeaderButtons ] ]
        [ span
            [ class [ Res.HeaderButton, Res.HeaderBtnMinimize ]
            , onClick (Minimize id)
            ]
            []
        , span
            [ class [ Res.HeaderButton, Res.HeaderBtnMaximize ]
            , onClick (ToggleMaximize id)
            ]
            []
        , span
            [ class [ Res.HeaderButton, Res.HeaderBtnClose ]
            , onClick (Close id)
            ]
            []
        ]


windowStyle : Window -> Html.Attribute Msg
windowStyle window =
    styles
        [ left (px window.position.x)
        , top (px window.position.y)
        , width (px window.size.width)
        , height (px window.size.height)
        ]
