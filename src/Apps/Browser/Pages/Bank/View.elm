module Apps.Browser.Pages.Bank.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.Bank.Models exposing (..)
import Apps.Browser.Pages.Bank.Messages exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Model -> Html Msg
view model =
    div [] [ text "TODO" ]
