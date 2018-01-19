module Apps.LanViewer.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Apps.LanViewer.Messages exposing (Msg(..))
import Apps.LanViewer.Models exposing (..)
import Apps.LanViewer.Resources exposing (..)
import Apps.LanViewer.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Never -> Never -> Html msg
view _ _ =
    div [] [ text "TODO" ]
