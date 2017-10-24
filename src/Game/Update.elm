module Game.Update exposing (update)

import Dict exposing (Dict)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages as Ws
import Decoders.Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Update as Account
import Game.Meta.Messages as Meta
import Game.Meta.Update as Meta
import Game.Servers.Messages as Servers
import Game.Servers.Update as Servers
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Storyline.Messages as Story
import Game.Storyline.Update as Story
import Game.Web.Messages as Web
import Game.Web.Update as Web
import Game.Network.Types as Network
import Game.Requests as Request exposing (Response)
import Game.Requests.Resync as Resync
import Game.Models exposing (..)
import Game.Messages exposing (..)
import Game.Events as Events


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Msg -> Model -> UpdateResponse
update msg model =
    case msg of
        AccountMsg msg ->
            onAccount msg model

        ServersMsg msg ->
            onServers msg model

        MetaMsg msg ->
            onMeta msg model

        StoryMsg msg ->
            onStory msg model

        WebMsg msg ->
            onWeb msg model

        Event event ->
            ( model, Cmd.none, Events.dispatcher event model )

        Resync ->
            onResync model

        Request data ->
            Request.receive model data
                |> Maybe.map (flip updateRequest model)
                |> Maybe.withDefault (Update.fromModel model)

        HandleConnected ->
            handleConnected model

        HandleJoinedAccount value ->
            handleJoinedAccount value model



-- internals


onResync : Model -> UpdateResponse
onResync model =
    let
        accountId =
            model
                |> getAccount
                |> Account.getId

        cmd =
            Resync.request accountId model
    in
        ( model, cmd, Dispatch.none )



-- childs


onAccount : Account.Msg -> Model -> UpdateResponse
onAccount msg game =
    Update.child
        { get = .account
        , set = (\account game -> { game | account = account })
        , toMsg = AccountMsg
        , update = (Account.update game)
        }
        msg
        game


onMeta : Meta.Msg -> Model -> UpdateResponse
onMeta msg game =
    Update.child
        { get = .meta
        , set = (\meta game -> { game | meta = meta })
        , toMsg = MetaMsg
        , update = (Meta.update game)
        }
        msg
        game


onStory : Story.Msg -> Model -> UpdateResponse
onStory msg game =
    Update.child
        { get = .story
        , set = (\story game -> { game | story = story })
        , toMsg = StoryMsg
        , update = (Story.update game)
        }
        msg
        game


onWeb : Web.Msg -> Model -> UpdateResponse
onWeb msg game =
    Update.child
        { get = .web
        , set = (\web game -> { game | web = web })
        , toMsg = WebMsg
        , update = (Web.update game)
        }
        msg
        game


onServers : Servers.Msg -> Model -> UpdateResponse
onServers msg game =
    Update.child
        { get = .servers
        , set = (\servers game -> { game | servers = servers })
        , toMsg = ServersMsg
        , update = (Servers.update game)
        }
        msg
        game



-- requests


updateRequest : Response -> Model -> UpdateResponse
updateRequest response model =
    case response of
        Request.Resync (Resync.Okay data) ->
            uncurry (flip onResyncResponse) data


onResyncResponse : Decoders.Game.ServersToJoin -> Model -> UpdateResponse
onResyncResponse servers model =
    let
        dispatch =
            servers.player
                |> List.map (bootstrapJoin servers.remote)
                |> Dispatch.batch
    in
        ( model, Cmd.none, dispatch )



-- events


handleConnected : Model -> UpdateResponse
handleConnected model =
    let
        dispatch =
            Dispatch.websocket (Ws.JoinChannel RequestsChannel Nothing)
    in
        ( model, Cmd.none, dispatch )


handleJoinedAccount : Value -> Model -> UpdateResponse
handleJoinedAccount value model =
    case Decode.decodeValue (Decoders.Game.bootstrap model) value of
        Ok ( model_, servers ) ->
            let
                dispatch =
                    servers.player
                        |> List.map (bootstrapJoin servers.remote)
                        |> Dispatch.batch
            in
                ( model_, Cmd.none, dispatch )

        Err reason ->
            let
                msg =
                    Debug.log "▶ " ("Bootstrap Error:\n" ++ reason)

                dispatch =
                    Dispatch.account <| Account.DoCrash "ERR_PORRA_RENATO" msg
            in
                ( model, Cmd.none, dispatch )


bootstrapJoin :
    Decoders.Game.RemoteServers
    -> Decoders.Game.Player
    -> Dispatch
bootstrapJoin remoteServers playerServer =
    let
        myDispatch =
            joinPlayer playerServer

        otherDispatches =
            playerServer.endpoints
                |> List.filterMap
                    (Servers.toSessionId >> flip Dict.get remoteServers)
                |> List.map (joinRemote playerServer)
    in
        Dispatch.batch (myDispatch :: otherDispatches)


joinPlayer : Decoders.Game.Player -> Dispatch
joinPlayer server =
    let
        cid =
            Servers.GatewayCId server.serverId
    in
        Dispatch.websocket <| Ws.JoinChannel (ServerChannel cid) Nothing


joinRemote : Decoders.Game.Player -> Decoders.Game.Remote -> Dispatch
joinRemote fromServer toServer =
    let
        maybeFromIp =
            fromServer.nips
                |> List.filter (Network.getId >> ((==) toServer.networkId))
                |> List.head
                |> Maybe.map Network.getIp
    in
        case maybeFromIp of
            Just fromIp ->
                let
                    channel =
                        ServerChannel <|
                            Servers.EndpointCId <|
                                Network.toNip toServer.networkId toServer.ip

                    payload =
                        -- TODO: include bounce_id after settling
                        -- it's field name
                        Encode.object
                            [ ( "gateway_ip", Encode.string fromIp )
                            , ( "password", Encode.string toServer.password )
                            ]
                in
                    Dispatch.websocket <|
                        (Ws.JoinChannel channel)
                            (Just payload)

            Nothing ->
                Dispatch.none
