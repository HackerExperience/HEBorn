module Game.Servers.Filesystem.Messages exposing (..)

import Game.Servers.Filesystem.Shared exposing (..)


{-| Mensagens:

  - HandleDelete

Recebida por dispatch para deletar um arquivo. Requer Id do arquivo.

  - HandleRename

Recebida por dispatch para renomear um arquivo. Requer Path até o arquivo e
Name do novo do arquivo.

  - HandleNewTextFile

Recebida por dispatch para criar um arquivo de texto. Requer Path até o
diretório e Name do arquivo de texto novo.

  - HandleNewDir

Recebida por dispatch para criar um novo diretório. Requer Path até o diretório
e Name do diretório novo.

  - HandleMove

Recebida por dispatch para mover um arquivo. Requer Id do arquivo e Path novo.

  - HandleAdded

Recebida por evento quando um arquivo é criado.

-}
type Msg
    = HandleDelete Id
    | HandleRename Id String
    | HandleNewTextFile Path Name
    | HandleNewDir Path Name
    | HandleMove Id Path
    | HandleAdded Id File
