module OS.WindowManager.View exposing (renderWindows)

import Html exposing (..)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Html.Attributes exposing (attribute)
import Css exposing (transform, translate2, asPairs, px, height, width, int, zIndex)
import Draggable
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Windows exposing (GameWindow(..))
import OS.WindowManager.Models
    exposing
        ( Window
        , WindowID
        , getOpenWindows
        , windowsFoldr
        )
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Style as Css
import Apps.Messages exposing (AppMsg(..))
import Apps.Explorer.View


{ id, class, classList } =
    Html.CssHelpers.withNamespace "wm"


styles : List Css.Mixin -> Attribute CoreMsg
styles =
    Css.asPairs >> style



-- rendrWindows : CoreModel -> Html CoreMsg


renderWindows model =
    (windowsFoldr (renderLoop model) [] (getOpenWindows model.os.wm))


renderLoop : CoreModel -> WindowID -> Window -> List (Html CoreMsg) -> List (Html CoreMsg)
renderLoop model id window acc =
    [ (renderWindow model window) ] ++ acc


renderWindow : CoreModel -> Window -> Html CoreMsg
renderWindow model window =
    case window.window of
        ExplorerWindow ->
            windowWrapper
                window
                (Html.map MsgApp (Html.map MsgExplorer (Apps.Explorer.View.view model.apps.explorer model.game)))


widndowClasses window =
    if (window.maximized) then
        class
            [ Css.Window
            , Css.Maximizeme
            ]
    else
        class [ Css.Window ]


windowWrapper : Window -> Html CoreMsg -> Html CoreMsg
windowWrapper window view =
    div
        [ widndowClasses window
        , windowStyle window
        ]
        [ Html.map MsgOS (Html.map MsgWM (header window))
        , div
            [ class [ Css.WindowBody ] ]
            [ view ]
        ]


windowTitle : Window -> String
windowTitle window =
    case window.window of
        SignUpWindow ->
            "Sign Up"

        ExplorerWindow ->
            "File Explorer"


windowIcon : Window -> String
windowIcon window =
    case window.window of
        SignUpWindow ->
            "signup"

        ExplorerWindow ->
            "explorer"


header : Window -> Html Msg
header window =
    div
        [ class [ Css.WindowHeader ]
        , Draggable.mouseTrigger window.id DragMsg
        ]
        [ headerTitle (windowTitle window) (windowIcon window)
        , headerButtons window.id
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
            [ class [ Css.HeaderButton, Css.HeaderBtnMaximize ]
            , onClick (ToggleMaximize id)
            ]
            []
        , span
            [ class [ Css.HeaderButton, Css.HeaderBtnClose ]
            , onClick (CloseWindow id)
            ]
            []
        ]


windowStyle : Window -> Html.Attribute CoreMsg
windowStyle window =
    styles
        [ transform (translate2 (px window.position.x) (px window.position.y))
        , width (px window.size.width)
        , height (px window.size.height)
        , zIndex (int window.position.z)
        ]
