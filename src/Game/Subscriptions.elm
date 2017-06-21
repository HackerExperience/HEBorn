module Game.Subscriptions exposing (subscriptions)

import Time exposing (Time, every, second)
import Core.Models as Core
import Game.Models exposing (..)
import Game.Messages exposing (..)
import Game.Meta.Messages as Meta


subscriptions : Model -> Core.Model -> Sub Msg
subscriptions model core =
    Sub.map MetaMsg (Time.every second Meta.Tick)
