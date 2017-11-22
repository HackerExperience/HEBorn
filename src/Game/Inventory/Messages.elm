module Game.Inventory.Messages exposing (Msg(..))

import Events.Server.Hardware.ComponentLinked as ComponentLinked
import Events.Server.Hardware.ComponentUnlinked as ComponentUnlinked


type Msg
    = HandleComponentLinked ComponentLinked.Data
    | HandleComponentUnlinked ComponentUnlinked.Data
