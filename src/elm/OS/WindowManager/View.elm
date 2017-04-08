module OS.WindowManager.View exposing (renderWindows)


import Html exposing (Html, div, text, button)
import Html.Attributes exposing (class, id, style)
import Html.Events exposing (onClick)
import Draggable

import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (Model)

import OS.WindowManager.Windows exposing (GameWindow(..))
import OS.WindowManager.Models exposing ( Window, WindowID
                                        , getOpenWindows, windowsFoldr)
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Messages exposing (OSMsg(..))

import Apps.Login.View


renderWindows : Model -> Html CoreMsg
renderWindows model =
    div [] (windowsFoldr (renderLoop model) [] (getOpenWindows model.os.wm))


renderLoop : Model -> WindowID -> Window -> List (Html CoreMsg) -> List (Html CoreMsg)
renderLoop model id window acc =
    [(renderWindow model window)] ++ acc


renderWindow : Model -> Window -> Html CoreMsg
renderWindow model window =
    case window.window of
        SignUpWindow ->
            windowWrapper
                window (Html.map MsgLogin (Apps.Login.View.view model.appLogin model.game))


windowWrapper : Window -> Html CoreMsg -> Html CoreMsg
windowWrapper window view =
    div [ class "window"
        , windowStyle window]
        [ Html.map MsgOS( Html.map MsgWM (header window))
        , div [ class "window-body"] [view]
        ]


header : Window -> Html Msg
header window =
    div
        [ class "window-header"
        , Draggable.mouseTrigger window.id DragMsg
        ]
        [ text "header"
        , button [ onClick (CloseWindow window.id) ] [text "X"]
        ]


-- TODO: Use elm-css instead of this
windowStyle window =
    let
        translate =
            "translate(" ++ (toString window.position.x) ++ "px, " ++ (toString window.position.y) ++ "px)"

        style_ =
            [ "transform" => translate
            , "padding" => "16px"
            , "background-color" => "blue"
            , "width" => "264px"
            , "cursor" => "move"
            ]
    in
        style style_


(=>) : a -> b -> ( a, b )
(=>) =
    (,)
