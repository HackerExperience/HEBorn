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
    | AccountServerIndexTopic
    | ServerLogIndexTopic
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

        AccountServerIndexTopic ->
            AccountChannel

        AccountBootstrapTopic ->
            AccountChannel

        ServerLogIndexTopic ->
            ServerChannel

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

        AccountServerIndexTopic ->
            "server.index"

        ServerLogIndexTopic ->
            "log.index"

        ServerFileIndexTopic ->
            "file.index"

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
