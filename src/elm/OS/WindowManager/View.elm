module OS.WindowManager.View exposing (renderWindows)


import Html exposing (Html, div, text)

import Core.Messages exposing (Msg(..))
import Core.Models exposing (Model)

import OS.WindowManager.Windows exposing (GameWindow(..))
import OS.WindowManager.Models exposing ( Window, WindowID
                                        , getOpenWindows, windowsFoldr)

import Apps.Login.View


renderWindows : Model -> Html Msg
renderWindows model =
    div [] (windowsFoldr (renderLoop model) [] (getOpenWindows model.os.wm))


renderLoop : Model -> WindowID -> Window -> List (Html Msg) -> List (Html Msg)
renderLoop model id window acc =
    [(renderWindow model window)] ++ acc


renderWindow : Model -> Window -> Html Msg
renderWindow model window =
    case window.window of
        SignUpWindow ->
            div [] [Html.map MsgLogin (Apps.Login.View.view model.appLogin model.game)]

