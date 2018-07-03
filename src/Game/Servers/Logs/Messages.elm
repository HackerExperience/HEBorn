module Game.Servers.Logs.Messages exposing (..)

import Game.Servers.Logs.Models exposing (..)


{-| Mensagens:

  - `HandleCreated` (evento)

Recebida quando um log é criado.

  - `HandleUpdateContent` (dispatch)

Atualiza o conteúdo do log. Requer Id do log e String com conteúdo novo.

  - `HandleHide` (dispatch)

Efetua request para esconder o log. Requer Id do log.

  - `HandleEncrypt` (dispatch)

Efetua request para encriptar o log. Requer Id do log e uma String com o
conteúdo descriptografado do log.

  - `HandleDecrypt` (dispatch)

Efetua request para desencriptar o log. Requer Id do log.

  - `HandleDelete` (dispatch)

Efetua request para deletar o log. Requer Id do log.

-}
type Msg
    = HandleCreated ID Log
    | HandleUpdateContent ID String
    | HandleHide ID
    | HandleEncrypt ID
    | HandleDecrypt ID String
    | HandleDelete ID
