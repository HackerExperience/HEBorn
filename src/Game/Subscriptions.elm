module Game.Subscriptions exposing (subscriptions)

import Time exposing (Time, every, second)
import Game.Models exposing (..)
import Game.Messages exposing (..)
import Game.Meta.Messages as Meta


subscriptions : Model -> Sub Msg
subscriptions model =
    -- this should be moved to meta
    Sub.map MetaMsg (Time.every second Meta.Tick)
