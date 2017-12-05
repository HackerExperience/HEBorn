module Game.Servers.Hardware.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Events.Server.Hardware.MotherboardAttached as MotherboardAttached
import Events.Server.Hardware.MotherboardDetached as MotherboardDetached


type Msg
    = HandleMotherboardAttached MotherboardAttached.Data
    | HandleMotherboardDetached MotherboardDetached.Data
    | Request RequestMsg


type RequestMsg
    = UpdateMotherboardRequest ResponseType
