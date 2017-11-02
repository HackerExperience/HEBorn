module Core.Subscribers.Servers exposing (dispatch)

import Core.Dispatch.Servers exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Notifications.Models exposing (Content(DownloadStarted))
import Game.Servers.Messages as Servers
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Servers.Shared exposing (CId)
import Game.Web.Messages as Web
import Apps.Browser.Messages as Browser


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Server id dispatch ->
            fromServer id dispatch

        Login gatewayNIP endpointIP password requester ->
            [ web <| Web.Login gatewayNIP endpointIP password requester ]

        FailLogin { sessionId, windowId, context, tabId } ->
            [ Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
            ]

        FetchedUrl { sessionId, windowId, context, tabId } response ->
            [ Browser.Fetched response
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
            ]



-- internals


fromServer : CId -> Server -> Subscribers
fromServer id dispatch =
    case dispatch of
        SetBounce a ->
            [ server id <| Servers.HandleSetBounce a ]

        SetEndpoint a ->
            [ server id <| Servers.HandleSetEndpoint a ]

        Filesystem dispatch ->
            fromFilesystem id dispatch

        Logs dispatch ->
            fromLogs id dispatch

        Processes dispatch ->
            fromProcesses id dispatch

        LogoutServer ->
            []

        FetchUrl url nId requester ->
            [ web <| Web.FetchUrl url nId id requester ]


fromFilesystem : CId -> Filesystem -> Subscribers
fromFilesystem id dispatch =
    case dispatch of
        DeleteFile a ->
            [ filesystem id <| Filesystem.HandleDelete a ]

        MoveFile a b ->
            [ filesystem id <| Filesystem.HandleMove a b ]

        RenameFile a b ->
            [ filesystem id <| Filesystem.HandleRename a b ]

        NewTextFile a ->
            [ filesystem id <| Filesystem.HandleNewTextFile a ]

        NewDir a ->
            [ filesystem id <| Filesystem.HandleNewDir a ]

        CreatedFile _ ->
            []


fromLogs : CId -> Logs -> Subscribers
fromLogs id dispatch =
    case dispatch of
        UpdateLog a b ->
            [ logs id <| Logs.LogMsg a <| Logs.HandleUpdateContent b ]

        EncryptLog a ->
            [ logs id <| Logs.LogMsg a Logs.HandleEncrypt ]

        HideLog a ->
            [ logs id <| Logs.HandleHide a ]

        DeleteLog a ->
            [ logs id <| Logs.HandleDelete a ]


fromProcesses : CId -> Processes -> Subscribers
fromProcesses id dispatch =
    case dispatch of
        PauseProcess a ->
            [ processes id <| Processes.HandlePause a ]

        ResumeProcess a ->
            [ processes id <| Processes.HandleResume a ]

        RemoveProcess a ->
            [ processes id <| Processes.HandleRemove a ]

        CompleteProcess a ->
            [ processes id <| Processes.HandleComplete a ]

        NewBruteforceProcess time a ->
            [ processes id <| Processes.HandleStartBruteforce a ]

        NewDownloadProcess time a b c ->
            (processes id <| Processes.HandleStartDownload a b c)
                :: (notifyServer id time False <| DownloadStarted a b)

        NewPublicDownloadProcess time a b c ->
            (processes id <| Processes.HandleStartPublicDownload a b c)
                :: (notifyServer id time False <| DownloadStarted a b)

        StartedProcess a ->
            [ processes id <| Processes.HandleProcessStarted a ]

        ConcludedProcess a ->
            [ processes id <| Processes.HandleProcessConclusion a ]

        ChangedProcesses a ->
            [ processes id <| Processes.HandleProcessesChanged a ]

        FailedBruteforceProcess a ->
            [ processes id <| Processes.HandleBruteforceFailed a ]
