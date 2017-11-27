module Events.BackFeed.Created exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.BackFeed.Models exposing (BackLog)
import Decoders.BackFeed


type alias Data =
    BackLog


handler : Handler Data event
handler event =
    decodeValue Decoders.BackFeed.backlog >> Result.map event
