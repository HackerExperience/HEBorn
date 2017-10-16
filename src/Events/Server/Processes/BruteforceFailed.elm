module Events.Server.Processes.BruteforceFailed exposing (Data, handler)

import Json.Decode exposing (Decoder, decodeValue, string)
import Json.Decode.Pipeline exposing (decode, required)
import Events.Types exposing (Handler)
import Game.Servers.Processes.Models exposing (ID)


type alias Data =
    { processId : ID
    , status : String
    }


handler : Handler Data event
handler event =
    decodeValue decoder >> Result.map event



-- internals


decoder : Decoder Data
decoder =
    decode Data
        |> required "process_id" string
        |> required "reason" string
