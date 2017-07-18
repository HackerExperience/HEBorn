module Apps.ServersGears.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.ServersGears.Messages exposing (Msg(..))
import Apps.ServersGears.Models exposing (..)
import Apps.ServersGears.Resources exposing (Classes(..), prefix)
import Apps.ServersGears.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ menuForDummy ] [ menuView model ]
