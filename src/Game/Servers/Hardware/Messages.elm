module Game.Servers.Hardware.Messages exposing (..)

import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Hardware.Models exposing (..)


{-| Mensagens:

  - HandleMotherBoardUpdate: recebida por dispatch, efetua request para atualizar
    a motherboard
  - HandleMotherboardUpdated: recebida por evento, atualiza a motherboard da
    model
  - SetMotherboard: recebida com a respota do request updateMotherboardRequest

-}
type Msg
    = HandleMotherboardUpdate Motherboard
    | HandleMotherboardUpdated Model
    | SetMotherboard Motherboard
