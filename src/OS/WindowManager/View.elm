module OS.WindowManager.View exposing (renderWindows, windowTitle)

import Html exposing (..)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick, onMouseDown)
import Html.CssHelpers
import Html.Attributes exposing (attribute)
import Css exposing (left, top, asPairs, px, height, width, int, zIndex)
import Draggable
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import Core.Dispatcher exposing (callWM)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Models
    exposing
        ( Window
        , WindowID
        , foldlWindows
        , filterOpenedWindows
        , getAppModel
        )
import OS.WindowManager.Context as Context
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Style as Css
import Apps.Models as Apps
import Apps.View as Apps


-- TODO: refactor most of this module to not rely so much on CoreMsg


{ id, class, classList } =
    Html.CssHelpers.withNamespace "wm"


styles : List Css.Mixin -> Attribute CoreMsg
styles =
    Css.asPairs >> style


renderWindows : CoreModel -> List (Html CoreMsg)
renderWindows core =
    foldlWindows (renderLoop core) [] (filterOpenedWindows core.os.wm)


renderLoop :
    CoreModel
    -> WindowID
    -> Window
    -> List (Html CoreMsg)
    -> List (Html CoreMsg)
renderLoop game id window html =
    (renderWindow id game window) :: html


renderWindow : WindowID -> CoreModel -> Window -> Html CoreMsg
renderWindow id model window =
    window
        |> getAppModel
        |> Apps.view model.game
        |> Html.map (WindowMsg id)
        |> Html.map MsgWM
        |> Html.map MsgOS
        |> windowWrapper id window


windowClasses : { a | maximized : Bool } -> Attribute msg
windowClasses window =
    if (window.maximized) then
        class
            [ Css.Window
            , Css.Maximizeme
            ]
    else
        class [ Css.Window ]


windowWrapper : WindowID -> Window -> Html CoreMsg -> Html CoreMsg
windowWrapper id window view =
    div
        [ windowClasses window
        , windowStyle window
        , onMouseDown (callWM (UpdateFocusTo (Just id)))
        ]
        [ Html.map MsgOS (Html.map MsgWM (header id window))
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


windowStyle : Window -> Html.Attribute CoreMsg
windowStyle window =
    styles
        [ left (px window.position.x)
        , top (px window.position.y)
        , width (px window.size.width)
        , height (px window.size.height)
        , zIndex (int window.position.z)
        ]
