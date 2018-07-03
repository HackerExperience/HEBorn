module Game.Servers.Notifications.Messages exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Notifications.Shared exposing (..)


{-| Mensagens:

  - `HandleGeneric` (dispatch)

Adiciona notificação genérica. Requer `Title` e `Content` da notificação.

  - `HandleDownloadStarted` (dispatch)

Adiciona notificação de download iniciado. Requer `NIP` do servidor afetado,
`StorageId` de destino e `FileEntry` de origem.
Deve ser recebeida após iniciar um processo de `Download` utilizando este
servidor.

  - `HandleDownloadConcluded` (dispatch)

Adiciona notificação de download concluído. Requer `NIP` do servidor afetado,
`StorageId` de destino e `FileEntry` de origem.
Deve ser recebeida após concluir um processo de `Download` que utilizava este
servidor.

  - `HandleUploadStarted` (dispatch)

Adiciona notificação de upload iniciado. Requer `NIP` do servidor afetado,
`StorageId` de destino e `FileEntry` de origem.

Deve ser recebeida após iniciar um processo de `Upload` utilizando este
servidor.

  - `HandleUploadConcluded` (dispatch)

Adiciona notificação de upload concluído. Requer `NIP` do servidor afetado,
`StorageId` de destino e `FileEntry` de origem.

Deve ser recebeida após concluir um processo de `Upload` que utilizava este
servidor.

  - `HandleBruteforceStarted` (dispatch)

Aiciona notificação de bruteforce iniciado. Requer `NIP` do servidor afetado.

Deve ser recebeida após iniciar um processo de `Bruteforce` utilizando este
servidor.

  - `HandleBruteforceConcluded` (dispatch)

Adiciona notificação de bruteforce concluído. Requer `NIP` do servidor afetado.

Deve ser recebeida após concluir um processo de `Bruteforce` que utilizava este
servidor.

  - `HandleReadAll` (dispatch)

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
