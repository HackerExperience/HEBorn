module Apps.LocationPicker.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Native.Untouchable
import Game.Data as Game
import Apps.LocationPicker.Messages exposing (Msg(..))
import Apps.LocationPicker.Models exposing (..)
import Apps.LocationPicker.Resources exposing (Classes(..), prefix)
import Apps.LocationPicker.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data ({ app } as model) =
    div
        [ menuForDummy
        , class [ Super ]
        ]
        [ Native.Untouchable.node "hemap" app.mapEId
        , menuView model
        ]
