module Game.Web.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events
import Utils.Update as Update
import Game.Models as Game
import Game.Web.Messages exposing (..)
import Game.Web.Types exposing (..)
import Game.Web.DNS as DNS
import Game.Web.Requests exposing (..)
import Game.Web.Requests.DNS as DNS
import Game.Web.Models exposing (..)
import Json.Encode as Encode
import OS.SessionManager.WindowManager.Models as WM
import Game.Meta.Types exposing (Context(..))
import Game.Network.Types exposing (IP)
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
            onRequest game (receive data) model

        FetchUrl serverId url requester ->
            let
                cmd =
                    DNS.request serverId url requester game
            in
                ( model, cmd, Dispatch.none )

        Event data ->
            updateEvent game data model



-- internals


onRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            ( model, Cmd.none, Dispatch.none )


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game response model =
    case response of
        DNS requester response ->
            onDNS game requester response model


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    case event of
        Events.Report (Ws.Joined ServerChannel (Just serverId) _) ->
            onJoined game serverId model

        Events.Report (Ws.JoinFailed ServerChannel (Just serverId) _) ->
            onJoinFailed game serverId model

        _ ->
            ( model, Cmd.none, Dispatch.none )


{-| Reports back the site information to the page.
-}
onDNS : Game.Model -> Requester -> DNS.Response -> Model -> UpdateResponse
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
    -> IP
    -> String
    -> Requester
    -> Model
    -> UpdateResponse
onLogin game serverId serverIp password requester model =
    let
        payload =
            Encode.object
                [ ( "server_id", Encode.string serverId )
                , ( "server_ip", Encode.string serverIp )
                , ( "password", Encode.string password )
                ]

        dispatch =
            Dispatch.websocket <|
                Ws.JoinChannel ServerChannel (Just serverId) (Just payload)

        model_ =
            startLoading serverId requester model
    in
        ( model_, Cmd.none, dispatch )


{-| Reports success back to the loading page.
-}
onJoined : Game.Model -> Servers.ID -> Model -> UpdateResponse
onJoined game serverId model0 =
    let
        ( maybeRequester, model ) =
            finishLoading serverId model0

        dispatch =
            case maybeRequester of
                Just { sessionId, windowId, context, tabId } ->
                    -- it may not be explicit, but sessionId
                    -- is always a gateway id
                    let
                        dispatch0 =
                            Browser.Login
                                |> Browser.SomeTabMsg tabId
                                |> Dispatch.browser ( sessionId, windowId )
                                    context

                        dispatch1 =
                            Dispatch.server sessionId <|
                                Servers.SetEndpoint serverId
                    in
                        Dispatch.batch dispatch0 dispatch1

                Nothing ->
                    Dispatch.none
    in
        ( model, Cmd.none, dispatch )


{-| Reports failure back to the loading page.
-}
onJoinFailed : Game.Model -> Servers.ID -> Model -> UpdateResponse
onJoinFailed game serverId model0 =
    let
        ( maybeRequester, model ) =
            finishLoading serverId model0

        dispatch =
            case maybeRequester of
                Just { sessionId, windowId, context, tabId } ->
                    Browser.LoginFailed
                        |> Browser.SomeTabMsg tabId
                        |> Dispatch.browser ( sessionId, windowId ) context

                Nothing ->
                    Dispatch.none
    in
        ( model, Cmd.none, dispatch )
