module Requests.Topics
    exposing
        ( Topic(..)
        , getDriver
        , getChannel
        , getWebsocketMsg
        , getHttpPath
        )

import Driver.Websocket.Channels exposing (..)
import Requests.Types exposing (..)


type Topic
    = AccountLoginTopic
    | AccountCreateTopic
    | AccountLogoutTopic
    | AccountBootstrapTopic
    | ServerBoostrapTopic
      -- sync
    | AccountSyncTopic
    | ServerLogsSyncTopic
    | ServerMetaSyncTopic
    | ServerFilesystemSyncTopic
    | ServerProcessesSyncTopic
      -- filesystem
    | ServerFileIndexTopic
    | ServerFileDeleteTopic
    | ServerFileMoveTopic
    | ServerFileRenameTopic
    | ServerFileCreateTopic


getChannel : Topic -> Channel
getChannel topic =
    case topic of
        AccountLogoutTopic ->
            RequestsChannel

        AccountBootstrapTopic ->
            AccountChannel

        ServerBoostrapTopic ->
            ServerChannel

        -- sync
        AccountSyncTopic ->
            ServerChannel

        ServerLogsSyncTopic ->
            ServerChannel

        ServerMetaSyncTopic ->
            ServerChannel

        ServerFilesystemSyncTopic ->
            ServerChannel

        ServerProcessesSyncTopic ->
            ServerChannel

        -- filesystem requests
        ServerFileIndexTopic ->
            ServerChannel

        ServerFileDeleteTopic ->
            ServerChannel

        ServerFileMoveTopic ->
            ServerChannel

        ServerFileRenameTopic ->
            ServerChannel

        ServerFileCreateTopic ->
            ServerChannel

        _ ->
            Debug.crash ("No channel for topic " ++ (toString topic))


getDriver : Topic -> Driver
getDriver topic =
    case topic of
        AccountCreateTopic ->
            HttpDriver

        AccountLoginTopic ->
            HttpDriver

        _ ->
            WebsocketDriver


getWebsocketMsg : Topic -> String
getWebsocketMsg topic =
    case topic of
        AccountLogoutTopic ->
            "account.logout"

        AccountBootstrapTopic ->
            "account.bootstrap"

        -- sync
        AccountSyncTopic ->
            "log.index"

        ServerLogsSyncTopic ->
            "file.index"

        ServerMetaSyncTopic ->
            "meta.index"

        ServerFilesystemSyncTopic ->
            "filesystem.index"

        ServerProcessesSyncTopic ->
            "processes.index"

        -- filesystem
        ServerFileDeleteTopic ->
            "file.delete"

        ServerFileMoveTopic ->
            "file.move"

        ServerFileRenameTopic ->
            "file.rename"

        ServerFileCreateTopic ->
            "file.create"

        _ ->
            Debug.crash ("No msg for topic " ++ (toString topic))


getHttpPath : Topic -> String
getHttpPath topic =
    case topic of
        AccountLoginTopic ->
            "account/login"

        AccountCreateTopic ->
            "account/register"

        _ ->
            Debug.crash ("No path for topic " ++ (toString topic))
