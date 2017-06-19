module OS.SessionManager.WindowManager.View exposing (view, windowTitle)

import OS.SessionManager.WindowManager.Models exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (..)
import Html exposing (..)
import Game.Models exposing (..)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick, onMouseDown)
import Html.CssHelpers
import Html.Attributes exposing (attribute)
import Css exposing (left, top, asPairs, px, height, width, int, zIndex)
import Draggable


-- import Core.Messages exposing (CoreMsg(..))
-- import Core.Models exposing (CoreModel)
-- import OS.Messages exposing (OSMsg(..))
-- import OS.SessionManager.WindowManager.Models
--     exposing
--         ( Window
--         , WindowID
--         , foldlWindows
--         , filterOpenedWindows
--         , getAppModel
--         )

import OS.SessionManager.WindowManager.Context as Context


-- import OS.SessionManager.WindowManager.Messages exposing (Msg(..))

import OS.SessionManager.WindowManager.Style as Css
import Apps.Models as Apps
import Apps.View as Apps


-- TODO: refactor most of this module to not rely on CoreMsg


{ id, class, classList } =
    Html.CssHelpers.withNamespace "wm"


view : WindowID -> GameModel -> Model -> Html Msg
view id game model =
    case getWindow id model of
        Just window ->
            window
                |> getAppModel
                |> Apps.view game
                |> Html.map (WindowMsg id)
                |> windowWrapper id window

        Nothing ->
            div [] []


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


windowClasses : Window -> Attribute Msg
windowClasses window =
    if (window.maximized) then
        class
            [ Css.Window
            , Css.Maximizeme
            ]
    else
        class [ Css.Window ]


windowWrapper : WindowID -> Window -> Html Msg -> Html Msg
windowWrapper id window view =
    div
        [ windowClasses window
        , windowStyle window
        , onMouseDown (UpdateFocusTo (Just id))
        ]
        [ header id window
        , div
            [ class [ Css.WindowBody ] ]
            [ view ]
        ]


windowTitle : Window -> String
windowTitle window =
    window
        |> getAppModel
        |> Apps.title


header : WindowID -> Window -> Html Msg
header id window =
    div
        [ Draggable.mouseTrigger id DragMsg ]
        [ div
            [ class [ Css.WindowHeader ]
            , onMouseDown (UpdateFocusTo (Just id))
            ]
            [ headerTitle (windowTitle window) (Apps.icon window.app)
            , headerContext id window.context
            , headerButtons id
            ]
        ]


headerContext : WindowID -> Context.Context -> Html Msg
headerContext id context =
    div []
        [ span
            [ class [ Css.HeaderContextSw ]
            , onClick (SwitchContext id)
            ]
            [ text (Context.toString context)
            ]
        ]


headerTitle : String -> String -> Html Msg
headerTitle title icon =
    div
        [ class [ Css.HeaderTitle ]
        , attribute "data-icon" icon
        ]
        [ text title ]


headerButtons : WindowID -> Html Msg
headerButtons id =
    div [ class [ Css.HeaderButtons ] ]
        [ span
            [ class [ Css.HeaderButton, Css.HeaderBtnMinimize ]
            , onClick (Minimize id)
            ]
            []
        , span
            [ class [ Css.HeaderButton, Css.HeaderBtnMaximize ]
            , onClick (ToggleMaximize id)
            ]
            []
        , span
            [ class [ Css.HeaderButton, Css.HeaderBtnClose ]
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
        , zIndex (int window.position.z)
        ]
