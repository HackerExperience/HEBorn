module Game.Servers.Hardware.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Events.Server.Hardware.MotherboardUpdated as MotherboardUpdated
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


type Msg
    = HandleMotherboardUpdated MotherboardUpdated.Data
    | HandleMotherboardUpdate Motherboard
    | Request RequestMsg


type RequestMsg
    = UpdateMotherboardRequest ResponseType
