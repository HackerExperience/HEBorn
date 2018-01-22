module Apps.Template.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Apps.Template.Messages exposing (Msg(..))
import Apps.Template.Models exposing (..)
import Apps.Template.Resources exposing (Classes(..), prefix)
import Apps.Template.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [ menuForDummy ] [ menuView model ]
