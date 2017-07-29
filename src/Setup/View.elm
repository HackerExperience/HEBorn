module Setup.View exposing (view)

import Game.Models as Game
import Native.Untouchable
import Html exposing (Html, div, text, br)
import Setup.Messages exposing (..)
import Setup.Models exposing (..)


view : Game.Model -> Model -> Html Msg
view game model =
    -- TODO: finish this
    div [] [ Native.Untouchable.node "hemap" "setupmap" ]
