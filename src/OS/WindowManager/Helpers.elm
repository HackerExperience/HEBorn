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
    -- this function is unsafe until someone adapt Game.Servers to allow
    -- proper reverse mapping functionality, but it should be enough for now
    let
        cids =
            getCIdsOfWindow config window model

        gateway =
            cids
                |> List.filter (Tuple.second >> Servers.isGateway)
                |> List.head

        endpoint =
            cids
                |> List.filter (Tuple.second >> Servers.isGateway >> not)
                |> List.head
    in
        case endpoint of
            Just _ ->
                endpoint

            Nothing ->
                case gateway of
                    Just ( _, server ) ->
                        let
                            servers =
                                serversFromConfig config

                            cid =
                                Servers.getEndpointCId server

                            server_ =
                                Maybe.andThen (flip Servers.get <| servers) cid
                        in
                            Maybe.uncurry cid server_

                    Nothing ->
                        Nothing



---- internals


getCIdsOfWindow : Config msg -> Window -> Model -> List ( CId, Server )
getCIdsOfWindow config window model =
    let
        appIds =
            listAppIds window

        appCIds =
            List.filterMap (flip getApp model >> Maybe.map getAppCId) appIds

        getAppendServer cid =
            case Servers.get cid <| serversFromConfig config of
                Just server ->
                    Just ( cid, server )

                Nothing ->
                    Nothing
    in
        appIds
            |> List.head
            |> Maybe.andThen (flip getWindowOfApp model)
            |> Maybe.andThen (flip getSessionOfWindow model)
            |> Maybe.map List.singleton
            |> Maybe.withDefault []
            |> (++) appCIds
            |> List.filterMap getAppendServer
