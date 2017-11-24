module OS.Header.ConnectionBarView exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Utils.Html.Attributes exposing (boolAttr)
import Game.Data exposing (Data)
import Game.Models as Game
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Network as Network
import Game.Account.Models as Account
import Game.Account.Bounces.Models as Bounces
import Game.Servers.Models as Servers exposing (Servers)
import Game.Servers.Shared as Servers
import OS.Header.Models exposing (..)
import OS.Header.Messages exposing (..)
import OS.Resources exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Data -> Model -> Html Msg
view ({ game } as data) { openMenu } =
    let
        account =
            Game.getAccount game

        activeGatewayCId =
            data
                |> Game.Data.getActiveCId
                |> Just

        gateways =
            account
                |> (.gateways)
                |> List.map Just

        activeBounce =
            data
                |> Game.Data.getActiveServer
                |> Servers.getBounce

        activeEndpointCId =
            game
                |> Game.getEndpoint
                |> Maybe.map Tuple.first

        endpoints =
            data
                |> Game.Data.getEndpoints
                |> List.map Just

        gatewayBounces =
            case activeEndpointCId of
                Nothing ->
                    game
                        |> Game.getBounces
                        |> List.map Just
                        |> (::) Nothing

                Just _ ->
                    [ activeBounce ]

        onGateway =
            account
                |> Account.getContext
                |> (==) Gateway

        servers =
            data
                |> Game.Data.getGame
                |> Game.getServers

        bounces =
            Account.getBounces account
    in
        div [ class [ Connection ] ]
            [ contextToggler onGateway (ContextTo Gateway)
            , gatewaySelector servers openMenu activeGatewayCId gateways
            , bounceSelector bounces openMenu activeBounce gatewayBounces
            , endpointSelector servers openMenu activeEndpointCId endpoints
            , contextToggler (not onGateway) (ContextTo Endpoint)
            ]



-- INTERNALS


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
    -> Maybe Servers.CId
    -> List (Maybe Servers.CId)
    -> Html Msg
gatewaySelector servers =
    let
        view cid =
            servers
                |> Servers.get cid
                |> Maybe.map gatewayLabel
    in
        selector [ SGateway ] SelectGateway GatewayOpen view


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
            servers
                |> Servers.getNIP cid
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
