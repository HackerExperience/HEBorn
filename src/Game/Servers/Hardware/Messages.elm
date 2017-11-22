module Game.Servers.Hardware.Messages exposing (..)

import Events.Server.Hardware.ComponentLinked as ComponentLinked
import Events.Server.Hardware.ComponentUnlinked as ComponentUnlinked
import Events.Server.Hardware.MotherboardAttached as MotherboardAttached
import Events.Server.Hardware.MotherboardDetached as MotherboardDetached


type Msg
    = HandleComponentLinked ComponentLinked.Data
    | HandleComponentUnlinked ComponentUnlinked.Data
    | HandleMotherboardAttached MotherboardAttached.Data
    | HandleMotherboardDetached MotherboardDetached.Data
