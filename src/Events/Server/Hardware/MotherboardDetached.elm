module Events.Server.Hardware.MotherboardDetached exposing (..)

import Json.Decode exposing (Decoder, decodeValue, map, field, string)
import Events.Types exposing (Handler)


type alias Data =
    { motherboardId : String
    }


handler : Handler Data event
handler event =
    decodeValue decoder >> Result.map event


decoder : Decoder Data
decoder =
    map Data (field "motherboard_id" string)
