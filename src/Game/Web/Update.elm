module Game.Web.Update exposing (update)

import Utils.React as React exposing (React)
import Core.Error as Error
import Game.Web.Config exposing (..)
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.Requests as Requests
import Game.Web.Requests.DNS as DNS
import Game.Web.Models exposing (..)
import Json.Encode as Encode
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Models as Servers
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Apps.Desktop exposing (Requester)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Login cid nip ip password data ->
            onLogin config cid nip ip password data model

        Request data ->
            updateRequest config (Requests.receive data) model

        FetchUrl url networkId cid requester ->
            onFetchUrl config url networkId cid requester model

        JoinedServer cid ->
            onJoinedServer config cid model

        HandleJoinServerFailed cid ->
            handleJoinFailed config cid model



-- internals


onFetchUrl :
    Config msg
    -> Url
    -> Network.ID
    -> Servers.CId
    -> Requester
    -> Model
    -> UpdateResponse msg
onFetchUrl config url networkId cid requester model =
    ( model
    , DNS.request url networkId cid requester config
        |> Cmd.map config.toMsg
        |> React.cmd
    )


updateRequest :
    Config msg
    -> Maybe Requests.Response
    -> Model
    -> UpdateResponse msg
updateRequest { onDNS } response model =
    case response of
        Just (Requests.DNS requester response) ->
            requester
                |> onDNS response
                |> React.msg
                |> (,) model

        Nothing ->
            ( model, React.none )


{-| Stores page reference and tries to login on server.
-}
onLogin :
    Config msg
    -> CId
    -> Network.NIP
    -> Network.IP
    -> String
    -> Requester
    -> Model
    -> UpdateResponse msg
onLogin config cid nip remoteIp password requester model =
    let
        gatewayIp =
            Network.getIp nip

        remoteNip =
            Network.toNip (Network.getId nip) remoteIp

        remoteCid =
            Servers.EndpointCId remoteNip

        payload =
            Encode.object
                [ ( "gateway_ip", Encode.string gatewayIp )
                , ( "password", Encode.string password )
                ]

        model_ =
            startLoading remoteNip cid requester model

        react =
            (Just payload)
                |> config.onLogin remoteCid
                |> React.msg
    in
        ( model_, react )


{-| Sets endpoint
-}
onJoinedServer : Config msg -> Servers.CId -> Model -> UpdateResponse msg
onJoinedServer config cid model =
    let
        servers =
            config.servers

        nip =
            case (Servers.get cid servers) of
                Just server ->
                    Servers.getActiveNIP server

                Nothing ->
                    "How did you do that?"
                        |> Error.notInServers
                        |> uncurry Native.Panic.crash

        ( maybeCIdReq, model_ ) =
            finishLoading nip model

        serverCid =
            Maybe.map Tuple.first maybeCIdReq

        react =
            case serverCid of
                Just serverCid ->
                    React.msg <| config.onJoinedServer serverCid cid

                Nothing ->
                    React.none
    in
        ( model_, react )


{-| Reports failure back to the loading page.
-}
handleJoinFailed : Config msg -> Servers.CId -> Model -> UpdateResponse msg
handleJoinFailed config cid model =
    let
        nip =
            case cid of
                Servers.EndpointCId nip ->
                    nip

                Servers.GatewayCId _ ->
                    "Failed to join a gateway"
                        |> Error.porra
                        |> uncurry Native.Panic.crash

        ( maybeCIdReq, model_ ) =
            finishLoading nip model

        maybeRequester =
            Maybe.map Tuple.second maybeCIdReq

        react =
            case maybeRequester of
                Just requester ->
                    React.msg <| config.onJoinFailed requester

                Nothing ->
                    React.none
    in
        ( model_, react )
