module OS.WindowManager.Helpers exposing (..)

import Utils.Maybe as Maybe
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId(..))
import OS.WindowManager.Config exposing (..)
import OS.WindowManager.Models exposing (..)


getActiveServer :
    Config msg
    -> Context
    -> ( CId, Server )
    -> Maybe ( CId, Server )
getActiveServer config context activeGateway =
    case context of
        Gateway ->
            Just activeGateway

        Endpoint ->
            getEndpointOfGateway config <| Tuple.second activeGateway


getEndpointOfGateway : Config msg -> Server -> Maybe ( CId, Server )
getEndpointOfGateway config server =
    let
        cid =
            Servers.getEndpointCId server

        server_ =
            Maybe.andThen (flip Servers.get <| serversFromConfig config) cid
    in
        Maybe.uncurry cid server_


getAppActiveServer : Config msg -> App -> Maybe ( CId, Server )
getAppActiveServer config app =
    let
        cid =
            getAppCId app
    in
        Maybe.map ((,) cid) <| Servers.get cid <| serversFromConfig config


getSessionId : Config msg -> CId
getSessionId =
    .activeServer >> Tuple.first


getGatewayOfWindow : Config msg -> Model -> Window -> Maybe ( CId, Server )
getGatewayOfWindow config model window =
    model
        |> getCIdsOfWindow config window
        |> List.filter (Tuple.second >> Servers.isGateway)
        |> List.head


getEndpointOfWindow : Config msg -> Model -> Window -> Maybe ( CId, Server )
getEndpointOfWindow config model window =
    model
        |> getCIdsOfWindow config window
        |> List.filter (Tuple.second >> Servers.isGateway >> not)
        |> List.head



---- internals


getCIdsOfWindow : Config msg -> Window -> Model -> List ( CId, Server )
getCIdsOfWindow config window model =
    let
        servers =
            serversFromConfig config

        appIds =
            listAppIds window

        cids =
            List.filterMap (flip getApp model >> Maybe.map getAppCId) appIds

        appendServers cid =
            case Servers.get cid servers of
                Just server ->
                    Just ( cid, server )

                Nothing ->
                    Nothing
    in
        case cids of
            _ :: _ :: _ ->
                -- window has two contexts, use them both
                List.filterMap appendServers cids

            _ :: _ ->
                -- window has a single  context, fetch it's counterpart
                cids
                    |> List.head
                    |> Maybe.map (getBoundServers config)
                    |> Maybe.withDefault []
                    |> List.filterMap appendServers

            _ ->
                -- window has no context, fetch session contexts
                appIds
                    |> List.head
                    |> Maybe.andThen (flip getWindowOfApp model)
                    |> Maybe.andThen (flip getSessionOfWindow model)
                    |> Maybe.andThen appendServers
                    |> Maybe.map List.singleton
                    |> Maybe.withDefault []


getBoundServers : Config msg -> CId -> List CId
getBoundServers config cid =
    let
        servers =
            serversFromConfig config

        maybeServer =
            Servers.get cid servers
    in
        case Servers.getGatewayOfEndpoint cid servers of
            Just gcid ->
                -- it was an endpoint cid, so join it with a gateway
                [ gcid, cid ]

            Nothing ->
                -- it was an gateway cid, so try to find its endpoint
                maybeServer
                    |> Maybe.andThen Servers.getEndpointCId
                    |> Maybe.map (flip (::) [ cid ])
                    |> Maybe.withDefault [ cid ]
