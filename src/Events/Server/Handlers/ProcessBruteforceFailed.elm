module Events.Server.Handlers.ProcessBruteforceFailed exposing (Data, handler)

import Json.Decode exposing (Decoder, decodeValue, string)
import Json.Decode.Pipeline exposing (decode, required)
import Events.Shared exposing (Handler)
import Game.Servers.Processes.Shared exposing (ID)


type alias Data =
    { processId : ID
    , status : String
    }


handler : Handler Data msg
handler toMsg =
    decodeValue decoder >> Result.map toMsg



-- internals


decoder : Decoder Data
decoder =
    decode Data
        |> required "process_id" string
        |> required "reason" string
