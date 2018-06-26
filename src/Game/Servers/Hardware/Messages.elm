module Game.Servers.Hardware.Messages exposing (..)

import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Hardware.Models exposing (..)


{-| Mensagens:

  - HandleMotherBoardUpdate

Recebida por dispatch, efetua request para atualizar a motherboard. Requer
a motherboard no estado desejado.

  - HandleMotherboardUpdated

Recebida por evento, atualiza a motherboard da model.

  - SetMotherboard

Recebida com a respota do request updateMotherboardRequest.

-}
type Msg
    = HandleMotherboardUpdate Motherboard
    | HandleMotherboardUpdated Model
    | SetMotherboard Motherboard
