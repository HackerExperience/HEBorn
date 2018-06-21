module Game.Servers.Notifications.Messages exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Notifications.Shared exposing (..)


{-| Mensagens:

  - HandleGeneric: adiciona notificação genérica
  - HandleDownloadStarted: adiciona notificação de download iniciado
  - HandleDownloadConcluded: adiciona notificação de download concluído
  - HandleUploadStarted: adiciona notificação de upload iniciado
  - HandleUploadConcluded: adiciona notificação de upload concluído
  - HandleBruteforceStarted: aiciona notificação de bruteforce iniciado
  - HandleBruteforceConcluded: adiciona notificação de bruteforce concluído
  - HandleReadAll: marca todas as notificações como lidas

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
