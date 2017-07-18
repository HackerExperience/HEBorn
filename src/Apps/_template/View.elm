module Apps.Template.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.Template.Messages exposing (Msg(..))
import Apps.Template.Models exposing (..)
import Apps.Template.Resources exposing (Classes(..), prefix)
import Apps.Template.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ menuForDummy ] [ menuView model ]
