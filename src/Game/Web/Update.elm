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
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Requester exposing (Requester)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        Login nip ip password data ->
            onLogin config nip ip password data model

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
updateRequest config response model =
    case response of
        Just (Requests.DNS requester response) ->
            ( model, React.none )

        Nothing ->
            ( model, React.none )


{-| Stores page reference and tries to login on server.
-}
onLogin :
    Config msg
    -> Network.NIP
    -> Network.IP
    -> String
    -> Requester
    -> Model
    -> UpdateResponse msg
onLogin config nip remoteIp password requester model =
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
            startLoading remoteNip requester model
    in
        ( model_, React.msg <| config.onLogin remoteCid (Just payload) )


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

        ( maybeRequester, model_ ) =
            finishLoading nip model

        serverCid =
            Maybe.map (.sessionId >> Servers.fromKey) maybeRequester

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
            case Servers.get cid config.servers of
                Just server ->
                    Servers.getActiveNIP server

                Nothing ->
                    "How did you do that?"
                        |> Error.notInServers
                        |> uncurry Native.Panic.crash

        ( maybeRequester, model_ ) =
            finishLoading nip model

        react =
            case maybeRequester of
                Just requester ->
                    React.msg <| config.onJoinFailed requester

                Nothing ->
                    React.none
    in
        ( model_, react )
