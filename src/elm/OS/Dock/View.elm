module OS.Dock.View exposing (view)


import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)

import Core.Messages exposing (Msg(..))
import Core.Models exposing (Model)
import OS.Messages exposing (OSMsg(..))

import OS.WindowManager.Messages as WMMsg
import OS.Dock.Models exposing ( Application
                               , getApplications)


view : Model -> (Html Msg)
view model =
    renderApplications model


renderApplications : Model -> (Html Msg)
renderApplications model =
    let
        applications = getApplications model.os.dock
        html = List.foldr (\app acc -> [renderApplication model app] ++ acc) [] applications
    in
        div [] html


renderApplication : Model -> Application -> (Html Msg)
renderApplication model application =
    div []
        [ button [ onClick (MsgOS (MsgWM (WMMsg.OpenWindow application.window))) ]
            [ text application.name ] ]
