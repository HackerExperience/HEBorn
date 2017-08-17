module Apps.Email.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.Email.Messages exposing (Msg(..))
import Apps.Email.Models exposing (..)
import Apps.Email.Resources exposing (Classes(..), prefix)
import Apps.Email.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ menuForDummy ] [ menuView model ]
