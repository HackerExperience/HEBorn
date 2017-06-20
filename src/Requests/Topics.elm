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
    | AccountServerIndexTopic
    | ServerLogIndexTopic
    | ServerFileIndexTopic


getChannel : Topic -> Channel
getChannel topic =
    case topic of
        AccountLogoutTopic ->
            RequestsChannel

        AccountServerIndexTopic ->
            AccountChannel

        ServerLogIndexTopic ->
            ServerChannel

        ServerFileIndexTopic ->
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

        AccountServerIndexTopic ->
            "server.index"

        ServerLogIndexTopic ->
            "log.index"

        ServerFileIndexTopic ->
            "server.index"

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
