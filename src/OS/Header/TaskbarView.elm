module OS.Header.TaskbarView exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Data as Game
import Game.Servers.Models as Servers
import Game.Servers.Notifications.Shared as ServersNotifications
import Game.Account.Notifications.Shared as AccountNotifications
import Game.Meta.Types.Notifications as Notifications
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.NotificationsView as Notifications
import OS.Header.AccountView as Account
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data { openMenu } =
    let
        ( chatView, chatBubble ) =
            chat openMenu

        ( serverView, serverBubble ) =
            servers data openMenu

        ( accountView, accountBubble ) =
            account data openMenu
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


servers : Game.Data -> OpenMenu -> ( Html Msg, Html Msg )
servers data openMenu =
    let
        notifications =
            data
                |> Game.getActiveServer
                |> Servers.getNotifications

        cid =
            Game.getActiveCId data

        view =
            Notifications.view ServersNotifications.render
                openMenu
                ServersOpen
                ServersIco
                "This server"
                (ServerReadAll cid)
                notifications

        bubble_ =
            notifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


account : Game.Data -> OpenMenu -> ( Html Msg, Html Msg )
account data openMenu =
    let
        game =
            Game.getGame data

        view =
            Account.view openMenu game

        bubble_ =
            data
                |> Game.getActiveServer
                |> Servers.getNotifications
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
