module Game.Meta.Subscriptions exposing (subscriptions)

import Time exposing (Time, every, second)
import Utils.Ports.Focus exposing (..)
import Game.Meta.Models exposing (..)
import Game.Meta.Messages exposing (..)


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ Time.every second Tick
        , focusedFetched <| handleFocusDecode Focused
        ]
