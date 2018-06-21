module Game.Servers.Logs.Messages exposing (..)

import Game.Servers.Logs.Models exposing (..)


{-| Mensagens:

  - HandleCreated: recebida por evento quando um log é criado
  - HandleUpdateContent: recebida por dispatch para atualizar o conteúdo do log
  - HandleHide: recebida por dispatch, efetua request para esconder o log
  - HandleEncrypt: recebida por dispatch, efetua request para encriptar o log
  - HandleDecrypt: recebida por dispatch, efetua request para desencriptar o log
  - HandleDelete: recebida por dispatch, efetua request para deletar o log

-}
type Msg
    = HandleCreated ID Log
    | HandleUpdateContent ID String
    | HandleHide ID
    | HandleEncrypt ID
    | HandleDecrypt ID String
    | HandleDelete ID
