module Events.Server.Hardware.ComponentUnlinked exposing (..)

import Json.Decode exposing (Decoder, decodeValue, string)
import Json.Decode.Pipeline exposing (decode, required)
import Events.Types exposing (Handler)


type alias Data =
    { slotId : String
    , componentId : String
    }


handler : Handler Data event
handler event =
    decodeValue decoder >> Result.map event


decoder : Decoder Data
decoder =
    decode Data
        |> required "slot_id" string
        |> required "component_id" string
