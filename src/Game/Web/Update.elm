module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.Requests as Requests
import Game.Web.Requests.DNS as DNS
import Game.Web.Models exposing (..)
import Json.Encode as Encode
import Game.Servers.Shared as Servers
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Driver.Websocket.Channels exposing (Channel(ServerChannel))
import Driver.Websocket.Messages as Ws
import Apps.Browser.Messages as Browser
import Game.Network.Types as Network


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

        HandleJoinedServer cid ->
            handleJoined game cid model

        HandleJoinServerFailed cid ->
            handleJoinFailed cid model



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
onDNS game { sessionId, windowId, context, tabId } response model =
    let
        dispatch =
            Browser.Fetched response
                |> Browser.SomeTabMsg tabId
                |> Dispatch.browser ( sessionId, windowId ) context
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

        payload =
            Encode.object
                [ ( "gateway_ip", Encode.string gatewayIp )
                , ( "password", Encode.string password )
                ]

        dispatch =
            Dispatch.websocket <|
                Ws.JoinChannel (ServerChannel remoteNip) (Just payload)

        model_ =
            startLoading remoteNip requester model
    in
        ( model_, Cmd.none, dispatch )


{-| Sets endpoint
-}
handleJoined : Game.Model -> Servers.CId -> Model -> UpdateResponse
handleJoined game cid model =
    let
        ( maybeRequester, model_ ) =
            finishLoading cid model

        servers =
            Game.getServers game

        serverCid =
            Maybe.andThen (.sessionId >> flip Servers.fromKey servers)
                maybeRequester

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
handleJoinFailed : Servers.CId -> Model -> UpdateResponse
handleJoinFailed cid model =
    let
        ( maybeRequester, model_ ) =
            finishLoading cid model

        dispatch =
            case maybeRequester of
                Just { sessionId, windowId, context, tabId } ->
                    Browser.LoginFailed
                        |> Browser.SomeTabMsg tabId
                        |> Dispatch.browser ( sessionId, windowId ) context

                Nothing ->
                    Dispatch.none
    in
        ( model_, Cmd.none, dispatch )
