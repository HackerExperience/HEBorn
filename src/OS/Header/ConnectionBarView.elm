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


view : Config msg -> Model -> Html msg
view ({ toMsg } as config) { openMenu } =
    let
        activeGatewayCId =
            config.activeGateway
                |> Tuple.first

        activeBounce =
            config.activeBounce

        activeEndpointCId =
            config.activeEndpointCid

        endpoints =
            config.endpoints
                |> List.map Just
                |> (::) Nothing

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
            [ contextToggler onGateway (toMsg <| ContextTo Gateway) activeEndpointCId
            , gatewaySelector config servers openMenu activeGatewayCId config.gateways
            , bounceSelector config bounces openMenu activeBounce gatewayBounces
            , endpointSelector config servers openMenu activeEndpointCId endpoints
            , contextToggler
                (not onGateway)
                (toMsg <| ContextTo Endpoint)
                activeEndpointCId
            ]



-- INTERNALS


contextToggler : Bool -> msg -> Maybe Servers.CId -> Html msg
contextToggler active handler activeEndpointCId =
    let
        classes =
            if active then
                [ Context, Selected ]
            else
                [ Context ]
    in
        case activeEndpointCId of
            Just cid ->
                span
                    [ onClick handler
                    , class classes
                    , boolAttr headerContextActiveAttrTag active
                    ]
                    []

            Nothing ->
                text ""


selector :
    Config msg
    -> List Class
    -> (Maybe a -> msg)
    -> OpenMenu
    -> (a -> Maybe (Html msg))
    -> OpenMenu
    -> Maybe a
    -> List (Maybe a)
    -> Html msg
selector { toMsg } classes wrapper kind render open active list =
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
            ( toMsg MouseEnterDropdown, toMsg MouseLeavesDropdown )
            wrapper
            (toMsg <| ToggleMenus kind)
            render_
            (open == kind)
            active
            list



-- GATEWAY


gatewaySelector :
    Config msg
    -> Servers.Model
    -> OpenMenu
    -> Servers.CId
    -> List Servers.CId
    -> Html msg
gatewaySelector { toMsg } servers open =
    let
        render_ _ cid =
            servers
                |> Servers.get cid
                |> Maybe.map gatewayLabel
    in
        customSelect
            [ class [ SGateway ] ]
            ( toMsg MouseEnterDropdown, toMsg MouseLeavesDropdown )
            (toMsg << SelectGateway)
            (toMsg <| ToggleMenus GatewayOpen)
            render_
            (open == GatewayOpen)


gatewayLabel : Servers.Server -> Html msg
gatewayLabel server =
    server
        |> Servers.getName
        |> text



-- ENDPOINT


endpointSelector :
    Config msg
    -> Servers.Model
    -> OpenMenu
    -> Maybe Servers.CId
    -> List (Maybe Servers.CId)
    -> Html msg
endpointSelector ({ toMsg } as config) servers =
    let
        view cid =
            servers
                |> Servers.get cid
                |> Maybe.map (endpointLabel servers cid)
    in
        selector config [ SEndpoint ] (toMsg << SelectEndpoint) EndpointOpen view


endpointLabel :
    Servers.Model
    -> Servers.CId
    -> Servers.Server
    -> Html msg
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
    Config msg
    -> Bounces.Model
    -> OpenMenu
    -> Maybe String
    -> List (Maybe String)
    -> Html msg
bounceSelector ({ toMsg } as config) bounces =
    let
        view id =
            case Bounces.get id bounces of
                Just { name } ->
                    Just <| text name

                Nothing ->
                    Nothing
    in
        selector config [ SBounce ] (toMsg << SelectBounce) BounceOpen view
