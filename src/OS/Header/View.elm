module OS.Header.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect)
import Utils.Html exposing (spacer)
import Game.Account.Bounces.Models as Bounces
import Game.Data as Game
import Game.Meta.Types as Meta
import Game.Meta.Models as Meta
import Game.Models as Game
import Game.Network.Types exposing (NIP)
import Game.Servers.Models as Servers
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import OS.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


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
        selector [ SGateway ] SelectGateway OpenGateway renderGateway


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
        selector [ SBounce ] SelectBounce OpenBounce renderBounce


endpointSelector :
    Game.Data
    -> OpenMenu
    -> Maybe NIP
    -> List (Maybe NIP)
    -> Html Msg
endpointSelector data =
    let
        renderEndpoint nip =
            if nip == ( "", "" ) then
                Just <| text "None"
            else
                let
                    ip =
                        Tuple.second nip

                    servers =
                        data
                            |> Game.getGame
                            |> Game.getServers

                    server =
                        servers
                            |> Servers.mapNetwork nip
                            |> Maybe.andThen (flip Servers.get servers)
                in
                    case server of
                        Just { name } ->
                            Just <| text (name ++ " (" ++ ip ++ ")")

                        Nothing ->
                            Just <| text ip
    in
        selector [ SEndpoint ] SelectEndpoint OpenEndpoint renderEndpoint


view : Game.Data -> Model -> Html Msg
view data ({ openMenu } as model) =
    let
        game =
            Game.getGame data

        meta =
            Game.getMeta game

        servers =
            Game.getServers game

        gateway =
            Just <| Game.getID data

        gateways =
            data
                |> Game.getGame
                |> Game.getAccount
                |> (.servers)
                |> List.map Just

        bounce =
            data
                |> Game.getServer
                |> Servers.getBounce

        endpoint =
            game
                |> Game.fromEndpoint
                |> Maybe.map (Game.getServer >> Servers.getNIP >> Just)
                |> Maybe.withDefault Nothing

        endpoints =
            -- TODO: add getters for database and servers
            data
                |> Game.getGame
                |> Game.getAccount
                |> (.database)
                |> (.servers)
                |> List.map (\server -> Just server.nip)
                |> (::) Nothing

        bounces =
            case endpoint of
                Just _ ->
                    []

                Nothing ->
                    game
                        |> Game.getAccount
                        |> (.bounces)
                        |> Dict.keys
                        |> List.map Just
                        |> (::) Nothing

        onGateway =
            Meta.Gateway == Meta.getContext meta
    in
        div [ class [ Header ] ]
            [ span [ class [ Logo ] ] [ text "D'LayDOS" ]
            , spacer
            , contextToggler onGateway (ContextTo Meta.Gateway)
            , gatewaySelector data openMenu gateway gateways
            , bounceSelector data openMenu bounce bounces
            , endpointSelector data openMenu endpoint endpoints
            , contextToggler (not onGateway) (ContextTo Meta.Endpoint)
            , spacer
            , notifications
            , button
                [ onClick Logout
                ]
                [ text "Logout" ]
            ]


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


notifications : Html Msg
notifications =
    node notificationsNode
        []
        [ ul []
            [ li []
                [ div [] [ text "Notifcations" ]
                , spacer
                , div [] [ text "Mark All as Read" ]
                ]
            , li [] [ text "@kress95 rejeitou #35" ]
            , li [] [ text "@pedrohlc pediu revisão a @kress95 em #35" ]
            , li [] [ text "Open Log Viewer" ]
            ]
        ]
