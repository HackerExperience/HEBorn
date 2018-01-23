module Apps.CtrlPanel.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Apps.CtrlPanel.Config exposing (..)
import Apps.CtrlPanel.Models exposing (..)
import Apps.CtrlPanel.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config -> Model -> Html msg
view config model =
    div [] [ text "TODO" ]
