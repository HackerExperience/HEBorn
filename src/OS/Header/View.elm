module OS.Header.View exposing (view)

import Dict
import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (..)
import UI.Widgets.CustomSelect exposing (customSelect)
import Utils.Html exposing (spacer)
import Game.Data as Game
import Game.Models as Game
import Game.Meta.Messages exposing (Context(..))
import Game.Servers.Models as Servers
import Game.Account.Bounces.Models as Bounces
import OS.Header.Messages exposing (..)
import OS.Header.Models exposing (..)
import OS.Resources as Res


{ id, class, classList } =
    Html.CssHelpers.withNamespace "os"


selector :
    OpenMenu
    -> OpenMenu
    -> (String -> Maybe (Html Msg))
    -> String
    -> List String
    -> Html Msg
selector kind open render active list =
    let
        wrapper =
            if kind == OpenGateway then
                SelectGateway
            else if kind == OpenBounce then
                SelectBounce
            else
                SelectEndpoint
    in
        customSelect CustomSelect
            wrapper
            (ToggleMenus kind)
            (\_ str -> render str)
            (open == kind)
            active
            list


renderGateway : Game.Data -> String -> Maybe (Html Msg)
renderGateway data id =
    case Servers.get id data.game.servers of
        Just { name, ip } ->
            Just (text <| name ++ " (" ++ ip ++ ")")

        Nothing ->
            Nothing


renderBounce : Game.Data -> String -> Maybe (Html Msg)
renderBounce data id =
    case Bounces.get id data.game.account.bounces of
        Just { name } ->
            Just <| text name

        Nothing ->
            Nothing


renderEndpoint : Game.Data -> String -> Maybe (Html Msg)
renderEndpoint data ip =
    if ip == "" then
        Just <| text "None"
    else
        let
            servers =
                data
                    |> Game.getGame
                    |> Game.getServers

            server =
                servers
                    |> Servers.mapNetwork ip
                    |> Maybe.andThen (flip Servers.get servers)
        in
            case server of
                Just { name } ->
                    Just <| text (name ++ " (" ++ ip ++ ")")

                Nothing ->
                    Just <| text ip


view : Game.Data -> Model -> Html Msg
view data ({ openMenu } as model) =
    let
        game =
            Game.getGame data

        servers =
            Game.getServers game

        gateway =
            game
                |> Game.fromGateway
                |> Maybe.map Game.getID
                |> Maybe.withDefault ""

        gateways =
            data
                |> Game.getGame
                |> Game.getAccount
                |> (.servers)

        bounce =
            data
                |> Game.getServer
                |> Servers.getBounce
                |> Maybe.withDefault ""

        bounces =
            game
                |> Game.getAccount
                |> (.bounces)
                |> Dict.keys
                |> (::) ""

        endpoint =
            game
                |> Game.fromEndpoint
                |> Maybe.map (Game.getServer >> Servers.getIP)
                |> Maybe.withDefault ""

        endpoints =
            data
                |> Game.getGame
                |> Game.getAccount
                |> (.database)
                |> (.servers)
                |> List.map .ip
                |> (::) ""
    in
        div [ class [ Res.Header ] ]
            [ selector OpenGateway
                openMenu
                (renderGateway data)
                gateway
                gateways
            , contextToggler (data.game.meta.context == Gateway)
                (ContextTo Gateway)
            , spacer
            , text "Bounce: "
            , selector OpenBounce
                openMenu
                (renderBounce data)
                bounce
                bounces
            , spacer
            , contextToggler (data.game.meta.context == Endpoint)
                (ContextTo Endpoint)
            , selector OpenEndpoint
                openMenu
                (renderEndpoint data)
                endpoint
                endpoints
            , button
                [ onClick Logout
                ]
                [ text "logout" ]
            ]


contextToggler : Bool -> Msg -> Html Msg
contextToggler active handler =
    span
        [ onClick handler ]
        [ text <|
            if active then
                "X"
            else
                "O"
        ]
