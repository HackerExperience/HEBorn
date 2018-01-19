module Apps.CtrlPanel.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Apps.CtrlPanel.Models exposing (..)
import Apps.CtrlPanel.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Never -> Never -> Html msg
view _ _ =
    div [] [ text "TODO" ]
