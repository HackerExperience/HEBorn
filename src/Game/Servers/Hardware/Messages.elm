module Game.Servers.Hardware.Messages exposing (..)

import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Hardware.Models exposing (..)


type Msg
    = HandleMotherboardUpdate Motherboard
    | HandleMotherboardUpdated Model
    | SetMotherboard Motherboard
