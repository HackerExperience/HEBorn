module Game.Servers.Notifications.Messages exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Notifications.Shared exposing (..)


{-| Mensagens, todas são recebidas por dispatch:

  - HandleGeneric

Adiciona notificação genérica. Requer Title e Content da notificação.

  - HandleDownloadStarted

Adiciona notificação de download iniciado. Requer NIP do servidor afetado,
StorageId de destino e FileEntry de origem.

  - HandleDownloadConcluded

Adiciona notificação de download concluído. Requer NIP do servidor afetado,
StorageId de destino e FileEntry de origem.

  - HandleUploadStarted

Adiciona notificação de upload iniciado. Requer NIP do servidor afetado,
StorageId de destino e FileEntry de origem.

  - HandleUploadConcluded

Adiciona notificação de upload concluído. Requer NIP do servidor afetado,
StorageId de destino e FileEntry de origem.

  - HandleBruteforceStarted

Aiciona notificação de bruteforce iniciado. Requer NIP do servidor afetado.

  - HandleBruteforceConcluded

Adiciona notificação de bruteforce concluído. Requer NIP do servidor afetado.

  - HandleReadAll

Marca todas as notificações como lidas.

-}
type Msg
    = HandleGeneric Title Message
    | HandleDownloadStarted NIP StorageId Filesystem.FileEntry
    | HandleDownloadConcluded NIP StorageId Filesystem.FileEntry
    | HandleUploadStarted NIP StorageId Filesystem.FileEntry
    | HandleUploadConcluded NIP StorageId Filesystem.FileEntry
    | HandleBruteforceStarted NIP
    | HandleBruteforceConcluded NIP
    | HandleReadAll
