module Game.Servers.Filesystem.Messages exposing (..)

import Game.Servers.Filesystem.Shared exposing (..)


{-| Mensagens:

  - `HandleDelete` (dispatch)

Deleta um arquivo. Requer `Id` do arquivo.

  - `HandleRename` (dispatch)

Renomeia um arquivo. Requer `Path` até o arquivo e `Name` do novo do arquivo.

  - `HandleNewTextFile` (dispatch)

Cria um arquivo de texto. Requer `Path` até o diretório e `Name` do arquivo de
texto novo.

  - `HandleNewDir` (dispatch)

Cria um novo diretório. Requer `Path` até o diretório e `Name` do diretório
novo.

  - `HandleMove` (dispatch)

Move um arquivo. Requer `Id` do arquivo e `Path` novo.

  - `HandleAdded` (evento)

Insere um arquivo novo na model.
Recebida quando um arquivo é criado.

-}
type Msg
    = HandleDelete Id
    | HandleRename Id String
    | HandleNewTextFile Path Name
    | HandleNewDir Path Name
    | HandleMove Id Path
    | HandleAdded Id File
