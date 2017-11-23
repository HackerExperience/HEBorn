module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Websocket as Ws
import Core.Dispatch.Servers as Servers
import Driver.Websocket.Channels exposing (Channel(ServerChannel))
import Game.Models as Game
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.Requests as Requests
import Game.Web.Requests.DNS as DNS
import Game.Web.Models exposing (..)
import Json.Encode as Encode
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Driver.Websocket.Messages as Ws
import Apps.Browser.Messages as Browser
import Game.Meta.Types.Network as Network


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Login nip ip password data ->
            onLogin game nip ip password data model

        Request data ->
            updateRequest game (Requests.receive data) model

        FetchUrl url networkId cid requester ->
            let
                cmd =
                    DNS.request url networkId cid requester game
            in
                ( model, cmd, Dispatch.none )

        JoinedServer cid ->
            onJoinedServer game cid model

        HandleJoinServerFailed cid ->
            handleJoinFailed game cid model



-- internals


updateRequest :
    Game.Model
    -> Maybe Requests.Response
    -> Model
    -> UpdateResponse
updateRequest game response model =
    case response of
        Just (Requests.DNS requester response) ->
            onDNS game requester response model

        Nothing ->
            ( model, Cmd.none, Dispatch.none )


{-| Reports back the site information to the page.
-}
onDNS : Game.Model -> Requester -> Response -> Model -> UpdateResponse
onDNS game requester response model =
    let
        dispatch =
            response
                |> Servers.FetchedUrl requester
                |> Dispatch.servers
    in
        ( model, Cmd.none, dispatch )


{-| Stores page reference and tries to login on server.
-}
onLogin :
    Game.Model
    -> Network.NIP
    -> Network.IP
    -> String
    -> Requester
    -> Model
    -> UpdateResponse
onLogin game nip remoteIp password requester model =
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

        dispatch =
            Dispatch.websocket <|
                Ws.Join (ServerChannel remoteCid) (Just payload)

        model_ =
            startLoading remoteNip requester model
    in
        ( model_, Cmd.none, dispatch )


{-| Sets endpoint
-}
onJoinedServer : Game.Model -> Servers.CId -> Model -> UpdateResponse
onJoinedServer game cid model =
    let
        servers =
            Game.getServers game

        nip =
            Servers.getNIP cid servers

        ( maybeRequester, model_ ) =
            finishLoading nip model

        serverCid =
            Maybe.map (.sessionId >> Servers.fromKey) maybeRequester

        dispatch =
            case serverCid of
                Just serverCid ->
                    Dispatch.server serverCid <|
                        Servers.SetEndpoint (Just cid)

                Nothing ->
                    Dispatch.none
    in
        ( model_, Cmd.none, dispatch )


{-| Reports failure back to the loading page.
-}
handleJoinFailed : Game.Model -> Servers.CId -> Model -> UpdateResponse
handleJoinFailed game cid model =
    let
        ( maybeRequester, model_ ) =
            case Servers.getNIPSafe cid (Game.getServers game) of
                Just nip ->
                    finishLoading nip model

                Nothing ->
                    ( Nothing, model )

        dispatch =
            case maybeRequester of
                Just requester ->
                    Servers.FailLogin requester
                        |> Dispatch.servers

                Nothing ->
                    Dispatch.none
    in
        ( model_, Cmd.none, dispatch )
