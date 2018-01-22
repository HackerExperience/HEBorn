module OS.Header.TaskbarView exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Notifications.Shared as ServersNotifications
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Meta.Types.Notifications as Notifications
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.NotificationsView as Notifications
import OS.Header.AccountView as Account
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html Msg
view config { openMenu } =
    let
        ( chatView, chatBubble ) =
            chat openMenu

        ( serverView, serverBubble ) =
            servers config openMenu

        ( accountView, accountBubble ) =
            account config openMenu
    in
        div [ class [ Taskbar ] ]
            [ chatView
            , chatBubble
            , serverView
            , serverBubble
            , accountView
            , accountBubble
            ]



-- INTERNALS


chat : OpenMenu -> ( Html Msg, Html Msg )
chat openMenu =
    let
        notifications =
            Dict.empty

        view =
            Notifications.view (always ( "", "" ))
                openMenu
                ChatOpen
                ChatIco
                "Chat"
                ChatReadAll
                notifications

        bubble_ =
            notifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


servers : Config msg -> OpenMenu -> ( Html Msg, Html Msg )
servers config openMenu =
    let
        notifications =
            config.serversNotifications

        view =
            Notifications.view ServersNotifications.render
                openMenu
                ServersOpen
                ServersIco
                "This server"
                ServerReadAll
                notifications

        bubble_ =
            notifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


account : Config msg -> OpenMenu -> ( Html Msg, Html Msg )
account config openMenu =
    let
        view =
            Account.view config openMenu

        bubble_ =
            config.serversNotifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


bubble : Int -> Html Msg
bubble num =
    flip (node bubbleNode) [ text <| toString num ] <|
        if num <= 0 then
            [ class [ Empty ] ]
        else
            []
