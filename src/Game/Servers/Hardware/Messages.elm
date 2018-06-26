module Game.Servers.Hardware.Messages exposing (..)

import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Hardware.Models exposing (..)


{-| Mensagens:

  - HandleMotherBoardUpdate (dispatch)

Efetua request para atualizar a motherboard. Requer a motherboard no estado
desejado.

  - HandleMotherboardUpdated (evento)

Atualiza a motherboard da model.

  - SetMotherboard

Recebida com a respota do request updateMotherboardRequest.

-}
type Msg
    = HandleMotherboardUpdate Motherboard
    | HandleMotherboardUpdated Model
    | SetMotherboard Motherboard
