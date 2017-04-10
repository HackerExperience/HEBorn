module OS.Dock.View exposing (view)

import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)
import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (CoreModel)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Models
    exposing
        ( Application
        , getApplications
        )


view : CoreModel -> Html CoreMsg
view model =
    renderApplications model


renderApplications : CoreModel -> Html CoreMsg
renderApplications model =
    let
        applications =
            getApplications model.os.dock

        html =
            List.foldr (\app acc -> [ renderApplication model app ] ++ acc) [] applications
    in
        div [] html


renderApplication : CoreModel -> Application -> Html CoreMsg
renderApplication model application =
    div []
        [ button [ onClick (MsgOS (MsgWM (OpenWindow application.window))) ]
            [ text application.name ]
        ]
