module OS.Header.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect)
import Utils.Html exposing (spacer)
import Game.Account.Bounces.Models as Bounces
import Game.Data as Game
import Game.Meta.Types exposing (..)
import Game.Account.Models as Account
import Game.Models as Game
import Game.Notifications.Models as Notifications
import Game.Servers.Models as Servers
import Game.Servers.Shared as Servers
import Game.Storyline.Models as Story
import OS.Resources exposing (..)
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [ class [ Header ] ]
        [ logo
        , connection data model
        , taskbar data model
        ]


bouncesGetter : Game.Model -> List (Maybe String)
bouncesGetter game =
    game
        |> Game.getAccount
        |> (.bounces)
        |> Dict.keys
        |> List.map Just
        |> (::) Nothing


endpointsGetter : Game.Model -> List (Maybe Servers.ID)
endpointsGetter game =
    let
        filterFunc =
            game
                |> Game.getServers
                |> flip Servers.mapNetwork
                |> List.filterMap
    in
        game
            |> Game.getAccount
            -- TODO: add getters for database and servers
            |> (.database)
            |> (.servers)
            |> Dict.keys
            |> filterFunc
            |> List.map Just
            |> (::) Nothing


logo : Html Msg
logo =
    div
        [ class [ Logo ] ]
        [ text "D'LayDOS" ]


connection : Game.Data -> Model -> Html Msg
connection ({ game } as data) { openMenu } =
    let
        account =
            Game.getAccount game

        gateway =
            Just <| Game.getID data

        gateways =
            account
                |> (.servers)
                |> List.map Just

        bounce =
            data
                |> Game.getServer
                |> Servers.getBounce

        endpoint =
            game
                |> Game.fromGateway
                |> Maybe.map Game.getServer
                |> Maybe.andThen Servers.getEndpoint

        endpoints =
            endpointsGetter game

        bounces =
            endpoint
                |> Maybe.map (always [])
                |> Maybe.withDefault (bouncesGetter game)

        onGateway =
            Gateway == Account.getContext account
    in
        div [ class [ Connection ] ]
            [ contextToggler onGateway (ContextTo Gateway)
            , gatewaySelector data openMenu gateway gateways
            , bounceSelector data openMenu bounce bounces
            , endpointSelector data openMenu endpoint endpoints
            , contextToggler (not onGateway) (ContextTo Endpoint)
            ]


selector :
    List Class
    -> (Maybe a -> Msg)
    -> OpenMenu
    -> (a -> Maybe (Html Msg))
    -> OpenMenu
    -> Maybe a
    -> List (Maybe a)
    -> Html Msg
selector classes wrapper kind render open active list =
    let
        render_ _ item =
            case item of
                Just item ->
                    render item

                Nothing ->
                    Just (text "None")
    in
        customSelect
            [ class classes ]
            CustomSelect
            wrapper
            (ToggleMenus kind)
            render_
            (open == kind)
            active
            list


gatewaySelector :
    Game.Data
    -> OpenMenu
    -> Maybe String
    -> List (Maybe String)
    -> Html Msg
gatewaySelector data =
    let
        renderGateway id =
            case Servers.get id data.game.servers of
                Just { name, nip } ->
                    let
                        ip =
                            Tuple.second nip
                    in
                        Just (text <| name ++ " (" ++ ip ++ ")")

                Nothing ->
                    Nothing
    in
        selector [ SGateway ] SelectGateway GatewayOpen renderGateway


bounceSelector :
    Game.Data
    -> OpenMenu
    -> Maybe String
    -> List (Maybe String)
    -> Html Msg
bounceSelector data =
    let
        renderBounce id =
            case Bounces.get id data.game.account.bounces of
                Just { name } ->
                    Just <| text name

                Nothing ->
                    Nothing
    in
        selector [ SBounce ] SelectBounce BounceOpen renderBounce


endpointSelector :
    Game.Data
    -> OpenMenu
    -> Maybe Servers.ID
    -> List (Maybe Servers.ID)
    -> Html Msg
endpointSelector data =
    let
        renderEndpoint id =
            if id == "" then
                Just <| text "None"
            else
                let
                    servers =
                        data
                            |> Game.getGame
                            |> Game.getServers

                    server =
                        Servers.get id servers
                in
                    case server of
                        Just { name, nip } ->
                            let
                                ip =
                                    Tuple.second nip
                            in
                                Just <| text (name ++ " (" ++ ip ++ ")")

                        Nothing ->
                            Nothing
    in
        selector [ SEndpoint ] SelectEndpoint EndpointOpen renderEndpoint


contextToggler : Bool -> Msg -> Html Msg
contextToggler active handler =
    let
        classes =
            if active then
                [ Context, Selected ]
            else
                [ Context ]
    in
        span [ onClick handler, class classes ] []


taskbar : Game.Data -> Model -> Html Msg
taskbar { game } { openMenu } =
    div [ class [ Taskbar ] ]
        [ notifications openMenu
            ChatOpen
            ChatIco
            "Chat"
            Dict.empty
        , notifications openMenu
            ServersOpen
            ServersIco
            "This server"
            Dict.empty
        , accountGear openMenu game
        ]


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode


notifications :
    OpenMenu
    -> OpenMenu
    -> Class
    -> String
    -> Notifications.Model
    -> Html Msg
notifications current activator uniqueClass title itens =
    if (current == activator) then
        visibleNotifications uniqueClass activator title itens
    else
        emptyNotifications uniqueClass activator


visibleNotifications :
    Class
    -> OpenMenu
    -> String
    -> Notifications.Model
    -> Html Msg
visibleNotifications uniqueClass activator title itens =
    let
        firstItem =
            li []
                [ div [] [ text (title ++ " notifications") ]
                , spacer
                , div [] [ text "Mark All as Read" ]
                ]

        lastItem =
            li [] [ text "..." ]

        itens_ =
            itens
                |> Dict.foldl
                    (\uid { content } acu ->
                        li [] [ text uid, br [] [], text "TODO" ]
                            :: acu
                    )
                    []

        contents =
            (firstItem :: (itens_ ++ [ lastItem ]))
                |> ul []
                |> List.singleton
                |> div []
                |> List.singleton

        attrs =
            [ class [ Notification, uniqueClass ]
            ]
    in
        indicator attrs contents


emptyNotifications : Class -> OpenMenu -> Html Msg
emptyNotifications uniqueClass activator =
    indicator
        [ class [ Notification, uniqueClass ]
        , onClick <| ToggleMenus activator
        ]
        []


pLi : Html msg -> Html msg
pLi elem =
    li [] <| List.singleton <| elem


accountGear : OpenMenu -> Game.Model -> Html Msg
accountGear openMenu game =
    if openMenu == AccountOpen then
        visibleAccountGear game
    else
        invisibleAccountGear


visibleAccountGear : Game.Model -> Html Msg
visibleAccountGear { account, story } =
    [ toggleCampaignBtn story
    , logoutBtn
    ]
        |> List.map pLi
        |> ul []
        |> List.singleton
        |> div []
        |> List.singleton
        |> indicator
            [ class [ Account ]
            ]


invisibleAccountGear : Html Msg
invisibleAccountGear =
    indicator
        [ class [ Account ]
        , onClick <| ToggleMenus AccountOpen
        ]
        []


toggleCampaignBtn : Story.Model -> Html Msg
toggleCampaignBtn { enabled } =
    button
        [ onClick ToggleCampaign ]
    <|
        List.singleton <|
            text <|
                if enabled then
                    "Go Multiplayer"
                else
                    "Go Campaign"


logoutBtn : Html Msg
logoutBtn =
    button
        [ onClick Logout ]
        [ text "Logout" ]
