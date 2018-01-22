module Events.Server.Handlers.MotherboardUpdated exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Shared exposing (Handler)
import Game.Servers.Hardware.Models as Hardware
import Decoders.Hardware


type alias Data =
    Hardware.Model


handler : Handler Data msg
handler toMsg =
    decodeValue Decoders.Hardware.hardware >> Result.map toMsg
