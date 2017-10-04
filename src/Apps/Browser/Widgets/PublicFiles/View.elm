module Apps.Browser.Widgets.PublicFiles.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))
import Apps.Browser.Widgets.PublicFiles.Model exposing (..)


type alias Config msg =
    {}


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


publicFiles : Config msg -> Model -> Html msg
publicFiles config model =
    div []
        []
