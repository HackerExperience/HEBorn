module Events.Server.Processes.Conclusion exposing (..)

import Json.Decode exposing (Decoder, decodeValue, field, string)
import Events.Types exposing (Handler)
import Game.Servers.Processes.Models exposing (..)


type alias Data =
    ID


handler : Handler Data event
handler event =
    decodeValue decoder >> Result.map event



-- internals


decoder : Decoder Data
decoder =
    field "process_id" string
