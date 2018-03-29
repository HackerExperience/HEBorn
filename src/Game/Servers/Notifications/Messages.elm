module Game.Servers.Notifications.Messages exposing (..)

import Game.Meta.Types.Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Notifications.Shared exposing (..)


type Msg
    = HandleGeneric Title Message
    | HandleDownloadStarted NIP StorageId Filesystem.FileEntry
    | HandleDownloadConcluded NIP StorageId Filesystem.FileEntry
    | HandleUploadStarted NIP StorageId Filesystem.FileEntry
    | HandleUploadConcluded NIP StorageId Filesystem.FileEntry
    | HandleBruteforceStarted NIP
    | HandleBruteforceConcluded NIP
    | HandleReadAll
