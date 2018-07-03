module Game.Servers.Processes.Config exposing (Config)

import Time exposing (Time)
import Core.Flags as Core
import Game.Servers.Shared as Servers exposing (CId)
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Messages exposing (..)


{-| Parâmetros especiais:

  - `onDownloadStarted`

Lançado quando um processo de download é iniciado. Passa StorageId alvo do
download e FileEntry de origem.

  - `onUploadStarted`

Lançado quando um processo de upload é iniciado. Passa StorageId alvo do
download e FileEntry de origem.

  - `onBruteforceStarted`

Lançado quando um processo de bruteforce é iniciado.

  - `onGenericNotification`

Utilizado para lançar notificações. Passa título e conteúdo da notificação.

-}
type alias Config msg =
    { flags : Core.Flags
    , toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    , cid : CId
    , nip : NIP
    , lastTick : Time
    , onDownloadStarted : String -> Filesystem.FileEntry -> msg
    , onUploadStarted : String -> Filesystem.FileEntry -> msg
    , onBruteforceStarted : msg
    , onGenericNotification : String -> String -> msg
    }
