module OS.Header.ConnectionBarView exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Attributes exposing (boolAttr)
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network as Network
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Models as Servers exposing (Servers)
import Game.Servers.Shared as Servers
import OS.Header.Config exposing (..)
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html Msg
view config { openMenu } =
    let
        activeGatewayCId =
            config.activeGateway
                |> Tuple.first

        activeBounce =
            config.activeBounce

        activeEndpointCId =
            config.activeEndpointCid

        endpoints =
            case config.endpoints of
                Just endpoints ->
                    List.map Just endpoints

                Nothing ->
                    []

        gatewayBounces =
            case activeEndpointCId of
                Nothing ->
                    bounces
                        |> Dict.keys
                        |> List.map Just
                        |> (::) Nothing

                Just _ ->
                    [ activeBounce ]

        onGateway =
            config.activeContext
                |> (==) Gateway

        servers =
            config.servers

        bounces =
            config.bounces
    in
        div [ class [ Connection ] ]
            [ contextToggler onGateway (ContextTo Gateway) activeEndpointCId
            , gatewaySelector servers openMenu activeGatewayCId config.gateways
            , bounceSelector bounces openMenu activeBounce gatewayBounces
            , endpointSelector servers openMenu activeEndpointCId endpoints
            , contextToggler
                (not onGateway)
                (ContextTo Endpoint)
                activeEndpointCId
            ]



-- INTERNALS


contextToggler : Bool -> Msg -> Maybe Servers.CId -> Html Msg
contextToggler active handler activeEndpointCId =
    let
        classes =
            if active then
                [ Context, Selected ]
            else
                [ Context ]

        span_ =
            case activeEndpointCId of
                Just cid ->
                    span
                        [ onClick handler
                        , class classes
                        , boolAttr headerContextActiveAttrTag active
                        ]
                        []

                Nothing ->
                    span [] []
    in
        span_


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



-- GATEWAY


gatewaySelector :
    Servers.Model
    -> OpenMenu
    -> Servers.CId
    -> List Servers.CId
    -> Html Msg
gatewaySelector servers open =
    let
        render_ _ cid =
            servers
                |> Servers.get cid
                |> Maybe.map gatewayLabel
    in
        customSelect
            [ class [ SGateway ] ]
            ( MouseEnterDropdown, MouseLeavesDropdown )
            SelectGateway
            (ToggleMenus GatewayOpen)
            render_
            (open == GatewayOpen)


gatewayLabel : Servers.Server -> Html Msg
gatewayLabel server =
    server
        |> Servers.getName
        |> text



-- ENDPOINT


endpointSelector :
    Servers.Model
    -> OpenMenu
    -> Maybe Servers.CId
    -> List (Maybe Servers.CId)
    -> Html Msg
endpointSelector servers =
    let
        view cid =
            servers
                |> Servers.get cid
                |> Maybe.map (endpointLabel servers cid)
    in
        selector [ SEndpoint ] SelectEndpoint EndpointOpen view


endpointLabel :
    Servers.Model
    -> Servers.CId
    -> Servers.Server
    -> Html Msg
endpointLabel servers cid server =
    let
        ip =
            server
                |> Servers.getActiveNIP
                |> Network.getIp

        name =
            Servers.getName server
    in
        name
            ++ " ("
            ++ ip
            ++ ")"
            |> text



-- BOUNCES


bounceSelector :
    Bounces.Model
    -> OpenMenu
    -> Maybe String
    -> List (Maybe String)
    -> Html Msg
bounceSelector bounces =
    let
        view id =
            case Bounces.get id bounces of
                Just { name } ->
                    Just <| text name

                Nothing ->
                    Nothing
    in
        selector [ SBounce ] SelectBounce BounceOpen view
