module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Utils.Update as Update
import Game.Models as Game
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.Requests as Requests
import Game.Web.Requests.DNS as DNS
import Game.Web.Models exposing (..)
import Json.Encode as Encode
import OS.SessionManager.WindowManager.Models as WM
import Game.Meta.Types exposing (Context(..))
import Game.Network.Types exposing (NIP)
import Game.Servers.Shared as Servers
import Game.Servers.Messages as Servers
import Driver.Websocket.Channels exposing (Channel(ServerChannel))
import Driver.Websocket.Reports as Ws
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

        FetchUrl nip url nid requester ->
            let
                cmd =
                    DNS.request nip nid url requester game
            in
                ( model, cmd, Dispatch.none )

        Event data ->
            updateEvent game data model



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


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        Events.Report (Ws.Joined (ServerChannel nip) _) ->
            onJoined game nip model

        Events.Report (Ws.JoinFailed (ServerChannel nip) _) ->
            onJoinFailed game nip model

        _ ->
            ( model, Cmd.none, Dispatch.none )


{-| Reports success back to the loading page.
-}
onJoined : Game.Model -> Network.NIP -> Model -> UpdateResponse
onJoined game nip model =
    let
        ( maybeRequester, model_ ) =
            finishLoading nip model

        dispatch =
            case maybeRequester of
                Just { sessionId, windowId, context, tabId } ->
                    -- it may not be explicit, but sessionId
                    -- is always a gateway id
                    Dispatch.server sessionId <|
                        Servers.SetEndpoint (Just nip)

                Nothing ->
                    Dispatch.none
    in
        ( model_, Cmd.none, dispatch )


{-| Reports failure back to the loading page.
-}
onJoinFailed : Game.Model -> Network.NIP -> Model -> UpdateResponse
onJoinFailed game nip model =
    let
        ( maybeRequester, model_ ) =
            finishLoading nip model

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
