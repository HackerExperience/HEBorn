module Game.Servers.Filesystem.Messages exposing (..)

import Game.Servers.Filesystem.Shared exposing (..)


{-| Mensagens:

  - HandleDelete: recebida por dispatch para deletar um arquivo
  - HandleRename: recebida por dispatch para renomear um arquivo
  - HandleNewTextFile: recebida por dispatch para criar um arquivo de texto
  - HandleNewDir: recebida por dispatch para criar um novo diretório
  - HandleMove: recebida por dispatch para mover um arquivo
  - HandleAdded: recebida por evento quando um arquivo é criado

-}
type Msg
    = HandleDelete Id
    | HandleRename Id String
    | HandleNewTextFile Path Name
    | HandleNewDir Path Name
    | HandleMove Id Path
    | HandleAdded Id File
