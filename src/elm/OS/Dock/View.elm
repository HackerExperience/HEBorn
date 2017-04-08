module OS.Dock.View exposing (view)


import Html exposing (Html, div, text, button)
import Html.Events exposing (onClick)

import Core.Messages exposing (CoreMsg(..))
import Core.Models exposing (Model)
import OS.Messages exposing (OSMsg(..))

import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Models exposing ( Application
                               , getApplications)


view : Model -> (Html CoreMsg)
view model =
    renderApplications model


renderApplications : Model -> (Html CoreMsg)
renderApplications model =
    let
        applications = getApplications model.os.dock
        html = List.foldr (\app acc -> [renderApplication model app] ++ acc) [] applications
    in
        div [] html


renderApplication : Model -> Application -> (Html CoreMsg)
renderApplication model application =
    div []
        [ button [ onClick (MsgOS (MsgWM (OpenWindow application.window))) ]
            [ text application.name ] ]
