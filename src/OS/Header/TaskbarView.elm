module OS.Header.TaskbarView exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Game.Servers.Notifications.Shared as ServersNotifications
import Game.Servers.Notifications.OnClick as ServersNotifications
import Game.Meta.Types.Notifications as Notifications
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.NotificationsView as Notifications
import OS.Header.AccountView as Account
import OS.Header.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config { openMenu } =
    let
        ( chatView, chatBubble ) =
            chat config openMenu

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


chat : Config msg -> OpenMenu -> ( Html msg, Html msg )
chat config openMenu =
    let
        notifications =
            Dict.empty

        view =
            Notifications.view config
                (always ( "", "" ))
                (always (config.batchMsg []))
                openMenu
                ChatOpen
                ChatIco
                "Chat"
                (config.toMsg ChatReadAll)
                notifications

        bubble_ =
            notifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


servers : Config msg -> OpenMenu -> ( Html msg, Html msg )
servers config openMenu =
    let
        notifications =
            config.serversNotifications

        view =
            Notifications.view config
                ServersNotifications.render
                (ServersNotifications.grabOnClick (serverActionConfig config))
                openMenu
                ServersOpen
                ServersIco
                "This server"
                (config.toMsg ServerReadAll)
                notifications

        bubble_ =
            notifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


account : Config msg -> OpenMenu -> ( Html msg, Html msg )
account config openMenu =
    let
        view =
            Account.view config openMenu

        bubble_ =
            config.accountNotifications
                |> Notifications.countUnreaded
                |> bubble
    in
        ( view, bubble_ )


bubble : Int -> Html msg
bubble num =
    flip
        (node bubbleNode)
        [ text <| toString num ]
    <|
        if num <= 0 then
            [ class [ Empty ] ]
        else
            []
