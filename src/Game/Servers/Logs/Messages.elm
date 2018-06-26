module Game.Servers.Logs.Messages exposing (..)

import Game.Servers.Logs.Models exposing (..)


{-| Mensagens:

  - HandleCreated

Recebida por evento quando um log é criado.

  - HandleUpdateContent

Recebida por dispatch para atualizar o conteúdo do log. Requer Id do log e
String com conteúdo novo.

  - HandleHide

Recebida por dispatch, efetua request para esconder o log. Requer Id do log.

  - HandleEncrypt

Recebida por dispatch, efetua request para encriptar o log. Requer Id do log e
conteúdo descriptografado do log.

  - HandleDecrypt

Recebida por dispatch, efetua request para desencriptar o log. Requer Id do
log.

  - HandleDelete

Recebida por dispatch, efetua request para deletar o log. Requer Id do log.

-}
type Msg
    = HandleCreated ID Log
    | HandleUpdateContent ID String
    | HandleHide ID
    | HandleEncrypt ID
    | HandleDecrypt ID String
    | HandleDelete ID
