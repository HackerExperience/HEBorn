module Game.Subscriptions exposing (subscriptions)

import Time exposing (Time, every, second)
import Core.Models exposing (CoreModel)
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(MsgMeta))
import Game.Meta.Messages exposing (MetaMsg(Tick))


subscriptions : GameModel -> CoreModel -> Sub GameMsg
subscriptions model core =
    Sub.map MsgMeta (Time.every second Tick)
