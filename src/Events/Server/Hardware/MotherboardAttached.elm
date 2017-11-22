module Events.Server.Hardware.MotherboardAttached exposing (..)

import Json.Decode exposing (decodeValue)
import Events.Types exposing (Handler)
import Game.Servers.Hardware.Models as Hardware
import Decoders.Hardware


type alias Data =
    Hardware.Model


handler : Handler Data event
handler event =
    decodeValue Decoders.Hardware.hardware >> Result.map event
