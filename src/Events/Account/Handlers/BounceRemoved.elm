module Events.Account.Handlers.BounceRemoved exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Bounces exposing (bounceId)
import Game.Account.Bounces.Shared exposing (ID)
import Events.Shared exposing (Handler)


type alias Data =
    ID


handler : Handler Data msg
handler toMsg =
    decodeValue bounceId >> Result.map toMsg
