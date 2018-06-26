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

  - DownloadRequestFailed

Recebida com a resposta do privateDownloadRequest e publicDownloadRequest.

  - UploadRequestFailed

Recebida com a resposta do uploadRequest.

  - HandleStartDownload

Recebida por dispatch, inicia processo de download. Requer NIP da network,
StorageId que armazenará o arquivo e o FileEntry do mesmo no servidor remoto.

  - HandleStartPublicDownload

Recebida por dispatch, inicia processo de download público. Requer NIP da
network, StorageId que armazenará o arquivo e o FileEntry do mesmo no servidor
remoto.

  - HandleStartUpload

Recebida por dispatch, inicia processo de upload. Requer CId do servidor de
origem, StorageId do servidor remoto e FileEntry do servidor de origem.

  - BruteforceRequestFailed

Recebida com a resposta do bruteforceRequest.

  - HandleStartBruteforce

Recebida por dispatch, inicia processo de bruteforce. Requer IP do servidor que
será invadido.

  - HandleBruteforceFailed

Recebida por evento quando o bruteforce falhar.

  - HandleProcessConclusion

Recebida por evento quando o processo for concluído.

  - HandleProcessesChanged

Recebida por evento quando a tabela de processos mudar.

  - HandlePause

Recebida por dispatch, pausa processo. Requer Id do processo a ser pausado.

  - HandleResume

Recebida por evento, despausa processo.

  - HandleRemove

Recebida por evento, remove processo.

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
