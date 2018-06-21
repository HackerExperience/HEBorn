module Game.Servers.Processes.Messages exposing (Msg(..))

import Events.Server.Handlers.ProcessCompleted as ProcessCompleted
import Events.Server.Handlers.ProcessBruteforceFailed as BruteforceFailed
import Events.Server.Handlers.ProcessesRecalcado as ProcessesRecalcado
import Game.Meta.Types.Network as Network
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Shared exposing (CId)
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Processes.Requests.Upload as Upload
import Game.Servers.Processes.Shared exposing (..)


{-| Mensagens :

  - DownloadRequestFailed: recebida com a resposta do privateDownloadRequest e
    publicDownloadRequest
  - UploadRequestFailed: recebida com a resposta do uploadRequest
  - HandleStartDownload: recebida por dispatch, inicia processo de download
  - HandleStartPublicDownload: recebida por dispatch, inicia processo de
    download público
  - HandleStartUpload: recebida por dispatch, inicia processo de upload
  - BruteforceRequestFailed: recebida com a resposta do bruteforceRequest
  - HandleStartBruteforce: recebida por dispatch, inicia processo de bruteforce
  - HandleBruteforceFailed: recebida por evento quando o bruteforce falhar
  - HandleProcessConclusion: recebida por evento quando o processo for concluído
  - HandleProcessesChanged: recebida por evento quando a tabela de processos mudar
  - HandlePause: recebida por dispatch, pausa processo
  - HandleResume: recebida por evento, despausa processo
  - HandleRemove: recebida por evento, remove processo

-}
type Msg
    = DownloadRequestFailed ID
    | UploadRequestFailed ID
    | HandleStartDownload Network.NIP Download.StorageId Filesystem.FileEntry
    | HandleStartPublicDownload Network.NIP Download.StorageId Filesystem.FileEntry
    | HandleStartUpload CId Upload.StorageId Filesystem.FileEntry
    | BruteforceRequestFailed ID
    | HandleStartBruteforce Network.IP
    | HandleBruteforceFailed BruteforceFailed.Data
    | HandleProcessConclusion ProcessCompleted.Data
    | HandleProcessesChanged ProcessesRecalcado.Data
    | HandlePause ID
    | HandleResume ID
    | HandleRemove ID
