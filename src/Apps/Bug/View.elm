module Apps.Bug.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Game.Data as Game
import Apps.Bug.Messages exposing (Msg(..))
import Apps.Bug.Models exposing (..)
import Apps.Bug.Resources exposing (Classes(..), prefix)
import Apps.Bug.Menu.View exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [ menuForDummy ]
        [ button [ onClick DummyToast ] [ text "Spawn useless toast" ]
        , menuView model
        ]
