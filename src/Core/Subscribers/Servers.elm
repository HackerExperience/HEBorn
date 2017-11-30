module Core.Subscribers.Servers exposing (dispatch)

import Core.Dispatch.Servers exposing (..)
import Core.Subscribers.Helpers exposing (..)
import Core.Messages as Core
import Game.Messages as Game
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models as Notifications
import Game.Servers.Messages as Servers
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Logs.Messages as Logs
import Game.Servers.Filesystem.Messages as Filesystem
import Game.Servers.Processes.Messages as Processes
import Game.Web.Messages as Web
import Apps.Browser.Messages as Browser


dispatch : Dispatch -> Subscribers
dispatch dispatch =
    case dispatch of
        Server id dispatch ->
            fromServer id dispatch

        Login gatewayNIP endpointIP password requester ->
            [ web <| Web.Login gatewayNIP endpointIP password requester ]

        -- REVIEW: we might be leaking too much detail
        FailLogin { sessionId, windowId, context, tabId } ->
            [ Browser.LoginFailed
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
            ]

        FetchedUrl { sessionId, windowId, context, tabId } response ->
            [ Browser.HandleFetched response
                |> Browser.SomeTabMsg tabId
                |> browser ( sessionId, windowId ) context
            ]



-- internals


fromServer : CId -> Server -> Subscribers
fromServer cid dispatch =
    case dispatch of
        SetBounce a ->
            [ server cid <| Servers.HandleSetBounce a ]

        SetEndpoint a ->
            [ server cid <| Servers.HandleSetEndpoint a ]

        Filesystem id dispatch ->
            fromFilesystem cid id dispatch

        Logs dispatch ->
            fromLogs cid dispatch

        Processes dispatch ->
            fromProcesses cid dispatch

        LogoutServer ->
            []

        FetchUrl url nId requester ->
            [ web <| Web.FetchUrl url nId cid requester ]


fromFilesystem : CId -> Servers.StorageId -> Filesystem -> Subscribers
fromFilesystem cid id dispatch =
    case dispatch of
        DeleteFile a ->
            [ filesystem cid id <| Filesystem.HandleDelete a ]

        MoveFile a b ->
            [ filesystem cid id <| Filesystem.HandleMove a b ]

        RenameFile a b ->
            [ filesystem cid id <| Filesystem.HandleRename a b ]

        NewTextFile a b ->
            [ filesystem cid id <| Filesystem.HandleNewTextFile a b ]

        NewDir a b ->
            [ filesystem cid id <| Filesystem.HandleNewDir a b ]

        FileAdded ( a, b ) ->
            [ filesystem cid id <| Filesystem.HandleAdded a b ]

        FileDownloaded _ ->
            []


fromLogs : CId -> Logs -> Subscribers
fromLogs cid dispatch =
    case dispatch of
        UpdateLog a b ->
            [ logs cid <| Logs.LogMsg a <| Logs.HandleUpdateContent b ]

        EncryptLog a ->
            [ logs cid <| Logs.LogMsg a Logs.HandleEncrypt ]

        HideLog a ->
            [ logs cid <| Logs.HandleHide a ]

        DeleteLog a ->
            [ logs cid <| Logs.HandleDelete a ]

        CreatedLog ( id, content ) ->
            [ logs cid <| Logs.HandleCreated id content ]


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

        NewBruteforceProcess a ->
            [ processes id <| Processes.HandleStartBruteforce a ]

        NewDownloadProcess a b c ->
            [ processes id <| Processes.HandleStartDownload a b c
            , serverNotif id <|
                Notifications.HandleInsert Nothing <|
                    Notifications.DownloadStarted a b c
            ]

        NewPublicDownloadProcess a b c ->
            [ processes id <| Processes.HandleStartPublicDownload a b c
            , serverNotif id <|
                Notifications.HandleInsert Nothing <|
                    Notifications.DownloadStarted a b c
            ]

        StartedProcess a ->
            [ processes id <| Processes.HandleProcessStarted a ]

        ConcludedProcess a ->
            [ processes id <| Processes.HandleProcessConclusion a ]

        ChangedProcesses a ->
            [ processes id <| Processes.HandleProcessesChanged a ]

        FailedBruteforceProcess a ->
            [ processes id <| Processes.HandleBruteforceFailed a ]
