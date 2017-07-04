module Apps.BounceManager.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Apps.BounceManager.Messages exposing (Msg(..))
import Apps.BounceManager.Models exposing (..)
import Apps.BounceManager.Resources exposing (Classes(..), prefix)
import Apps.BounceManager.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div [ class [ Dummy ] ]
        [ menuView model ]
