module Apps.LanViewer.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Apps.LanViewer.Models exposing (..)
import Apps.LanViewer.Config exposing (..)
import Apps.LanViewer.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config -> Model -> Html msg
view config model =
    div [] [ text "TODO" ]
