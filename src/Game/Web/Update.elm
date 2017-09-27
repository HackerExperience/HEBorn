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


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Login id ip password data ->
            onLogin game id ip password data model

        Request data ->
            updateRequest game (Requests.receive data) model

        FetchUrl serverId url nid requester ->
            let
                cmd =
                    DNS.request serverId url nid requester game
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
    -> Servers.ID
    -> NIP
    -> String
    -> Requester
    -> Model
    -> UpdateResponse
onLogin game serverId nip password requester model =
    let
        networkId =
            Tuple.first nip

        remoteIp =
            Tuple.second nip

        payload =
            Encode.object
                [ ( "gateway_id", Encode.string serverId )
                , ( "network_id", Encode.string networkId )
                , ( "server_ip", Encode.string remoteIp )
                , ( "password", Encode.string password )
                ]

        dispatch =
            Dispatch.websocket <|
                Ws.JoinChannel ServerChannel (Just remoteIp) (Just payload)

        model_ =
            startLoading remoteIp requester model
    in
        ( model_, Cmd.none, dispatch )


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        Events.Report (Ws.Joined ServerChannel (Just serverId) _) ->
            onJoined game serverId model

        Events.Report (Ws.JoinFailed ServerChannel (Just serverId) _) ->
            onJoinFailed game serverId model

        _ ->
            ( model, Cmd.none, Dispatch.none )


{-| Reports success back to the loading page.
-}
onJoined : Game.Model -> Servers.ID -> Model -> UpdateResponse
onJoined game serverId model =
    let
        ( maybeRequester, model_ ) =
            finishLoading serverId model

        dispatch =
            case maybeRequester of
                Just { sessionId, windowId, context, tabId } ->
                    -- it may not be explicit, but sessionId
                    -- is always a gateway id
                    Dispatch.server sessionId <|
                        Servers.SetEndpoint (Just serverId)

                Nothing ->
                    Dispatch.none
    in
        ( model_, Cmd.none, dispatch )


{-| Reports failure back to the loading page.
-}
onJoinFailed : Game.Model -> Servers.ID -> Model -> UpdateResponse
onJoinFailed game serverId model =
    let
        ( maybeRequester, model_ ) =
            finishLoading serverId model

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
