module OS.Header.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect)
import Utils.Html exposing (spacer)
import Utils.Html.Attributes exposing (boolAttr)
import Game.Account.Bounces.Models as Bounces
import Game.Data as Game
import Game.Meta.Types exposing (..)
import Game.Account.Models as Account
import Game.Models as Game
import Game.Notifications.Models as Notifications
import Game.Network.Types exposing (NIP)
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


headerBounces : Game.Model -> List (Maybe String)
headerBounces game =
    Game.bounces game
        |> List.map Just
        |> (::) Nothing


headerEndpoints : Game.Model -> List (Maybe ( NIP, Servers.ID ))
headerEndpoints ({ account } as game) =
    account.joinedEndpoints
        |> List.map
            (\nip ->
                idByNip game nip
                    |> Maybe.andThen
                        (\id -> Just ( nip, id ))
            )
        |> List.filter ((/=) Nothing)
        |> (::) Nothing


headerEndpoint : Game.Model -> Maybe ( NIP, Servers.ID )
headerEndpoint game =
    Maybe.andThen
        (\id ->
            serverById game id
                |> Maybe.map
                    (.nip >> flip (,) id)
        )
        (gameEndpointId game)


gameEndpointId : Game.Model -> Maybe Servers.ID
gameEndpointId game =
    game
        |> Game.fromGateway
        |> Maybe.map Game.getServer
        |> Maybe.andThen Servers.getEndpoint


serverById : Game.Model -> Servers.ID -> Maybe Servers.Server
serverById game =
    flip Servers.get game.servers


idByNip : Game.Model -> NIP -> Maybe Servers.ID
idByNip game =
    flip Servers.mapNetwork game.servers


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
                |> (.gateways)
                |> List.map Just

        bounce =
            data
                |> Game.getServer
                |> Servers.getBounce

        endpointNip =
            headerEndpoint game

        endpoints =
            headerEndpoints game

        bounces =
            gameEndpointId game
                |> Maybe.map (always [])
                |> Maybe.withDefault (headerBounces game)

        onGateway =
            Gateway == Account.getContext account
    in
        div [ class [ Connection ] ]
            [ contextToggler onGateway (ContextTo Gateway)
            , gatewaySelector data openMenu gateway gateways
            , bounceSelector data openMenu bounce bounces
            , endpointSelector data openMenu endpointNip endpoints
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
            ( MouseEnterDropdown, MouseLeavesDropdown )
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


endpointSelectMsg : Maybe ( NIP, Servers.ID ) -> Msg
endpointSelectMsg item =
    item
        |> Maybe.map Tuple.second
        |> SelectEndpoint


endpointSelector :
    Game.Data
    -> OpenMenu
    -> Maybe ( NIP, Servers.ID )
    -> List (Maybe ( NIP, Servers.ID ))
    -> Html Msg
endpointSelector data =
    selector [ SEndpoint ]
        endpointSelectMsg
        EndpointOpen
    <|
        \( ( _, ip ), _ ) ->
            Just <| text ip


contextToggler : Bool -> Msg -> Html Msg
contextToggler active handler =
    let
        classes =
            if active then
                [ Context, Selected ]
            else
                [ Context ]
    in
        span
            [ onClick handler
            , class classes
            , boolAttr "active" active
            ]
            []


activeServerGetter : Game.Model -> Maybe Servers.ID
activeServerGetter game =
    game
        |> Game.getAccount
        |> (\z ->
                case Account.getContext z of
                    Gateway ->
                        Account.getGateway z

                    Endpoint ->
                        gameEndpointId game
           )


taskbar : Game.Data -> Model -> Html Msg
taskbar { game } { openMenu } =
    let
        chatNotifications =
            Dict.empty

        activeServer =
            activeServerGetter game

        serverNotifications =
            activeServer
                |> Maybe.andThen (flip Servers.get game.servers)
                |> Maybe.map (.notifications)
                |> Maybe.withDefault (Dict.empty)

        accountNotifications =
            game.account.notifications

        serverReadAll =
            case activeServer of
                Just activeServer ->
                    ServerReadAll activeServer

                Nothing ->
                    Debug.crash "The OS needs a server to run!"
    in
        div [ class [ Taskbar ] ]
            [ notifications openMenu
                ChatOpen
                ChatIco
                "Chat"
                ChatReadAll
                chatNotifications
            , notificationsBubble <|
                Notifications.countUnreaded chatNotifications
            , notifications openMenu
                ServersOpen
                ServersIco
                "This server"
                serverReadAll
                serverNotifications
            , notificationsBubble <|
                Notifications.countUnreaded serverNotifications
            , accountGear openMenu game
            , notificationsBubble <|
                Notifications.countUnreaded accountNotifications
            ]


indicator : List (Attribute a) -> List (Html a) -> Html a
indicator =
    node indicatorNode


bubble : List (Attribute a) -> List (Html a) -> Html a
bubble =
    node bubbleNode


notificationsBubble : Int -> Html Msg
notificationsBubble num =
    flip bubble [ text <| toString num ] <|
        if num <= 0 then
            [ class [ Empty ] ]
        else
            []


notifications :
    OpenMenu
    -> OpenMenu
    -> Class
    -> String
    -> Msg
    -> Notifications.Model
    -> Html Msg
notifications current activator uniqueClass title readAll itens =
    if (current == activator) then
        visibleNotifications uniqueClass activator title readAll itens
    else
        emptyNotifications uniqueClass activator


visibleNotifications :
    Class
    -> OpenMenu
    -> String
    -> Msg
    -> Notifications.Model
    -> Html Msg
visibleNotifications uniqueClass activator title readAll itens =
    let
        firstItem =
            li []
                [ div [] [ text (title ++ " notifications") ]
                , spacer
                , div [ onClick readAll ] [ text "Mark All as Read" ]
                ]

        lastItem =
            li [] [ text "..." ]

        itens_ =
            itens
                |> Dict.foldl
                    (\id { content } acu ->
                        li []
                            [ text <| toString id
                            , br [] []
                            , text "TODO"
                            ]
                            :: acu
                    )
                    []

        contents =
            (firstItem :: (itens_ ++ [ lastItem ]))
                |> ul []
                |> List.singleton
                |> div
                    [ onMouseEnter MouseEnterDropdown
                    , onMouseLeave MouseLeavesDropdown
                    ]
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
        |> div
            [ onMouseEnter MouseEnterDropdown
            , onMouseLeave MouseLeavesDropdown
            ]
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
