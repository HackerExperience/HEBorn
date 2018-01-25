module Events.Account.Handlers.BounceCreated exposing (Data, handler)

import Json.Decode exposing (decodeValue)
import Decoders.Bounces exposing (bounceWithId)
import Game.Account.Bounces.Models exposing (Bounce)
import Game.Account.Bounces.Shared exposing (ID)
import Events.Shared exposing (Handler)


type alias Data =
    ( ID, Bounce )


handler : Handler Data msg
handler toMsg =
    decodeValue bounceWithId >> Result.map toMsg
