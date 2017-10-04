module Apps.Browser.Pages.Webserver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Webserver.Models exposing (Model)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Model -> Html Never
view model =
    div [] [ text "TODO" ]
