module Game.Update exposing (update)

import Dict exposing (Dict)
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Error as Error
import Core.Dispatch.Websocket as Ws
import Core.Dispatch.Core as Core
import Driver.Websocket.Channels exposing (Channel(ServerChannel))
import Decoders.Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Update as Account
import Game.Meta.Messages as Meta
import Game.Meta.Update as Meta
import Game.Meta.Models as Meta
import Game.Servers.Messages as Servers
import Game.Servers.Update as Servers
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Storyline.Messages as Story
import Game.Storyline.Update as Story
import Game.Inventory.Messages as Inventory
import Game.Inventory.Update as Inventory
import Game.Web.Messages as Web
import Game.Web.Update as Web
import Game.LogStream.Messages as LogFlix
import Game.LogStream.Update as LogFlix
import Game.Meta.Types.Network as Network
import Game.Requests as Request exposing (Response)
import Game.Requests.Resync as Resync
import Game.Config exposing (..)
import Game.Messages exposing (..)
import Game.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        AccountMsg msg ->
            onAccount config msg model

        ServersMsg msg ->
            onServers config msg model

        MetaMsg msg ->
            onMeta config msg model

        StoryMsg msg ->
            onStory config msg model

        InventoryMsg msg ->
            onInventory config msg model

        WebMsg msg ->
            onWeb config msg model

        LogFlixMsg msg ->
            onLogFlix config msg model

        Resync ->
            onResync config model

        Request data ->
            Request.receive model data
                |> Maybe.map (flip (updateRequest config) model)
                |> Maybe.withDefault (Update.fromModel model)

        HandleJoinedAccount value ->
            handleJoinedAccount config value model



-- internals


onResync : Config msg -> Model -> UpdateResponse msg
onResync config model =
    let
        accountId =
            model
                |> getAccount
                |> Account.getId

        cmd =
            Cmd.map config.toMsg <| Resync.request accountId model
    in
        ( model, cmd, Dispatch.none )



-- childs


onAccount : Config msg -> Account.Msg -> Model -> UpdateResponse msg
onAccount config msg model =
    let
        lastTick =
            Meta.getLastTick (getMeta model)

        config_ =
            accountConfig lastTick (getFlags model) config

        ( account, cmd, dispatch ) =
            Account.update config_ model msg <| getAccount model

        model_ =
            { model | account = account }
    in
        ( model_, cmd, dispatch )


onMeta : Config msg -> Meta.Msg -> Model -> UpdateResponse msg
onMeta config msg game =
    Update.child
        { get = .meta
        , set = (\meta game -> { game | meta = meta })
        , toMsg = MetaMsg >> config.toMsg
        , update = (Meta.update game)
        }
        msg
        game


onStory : Config msg -> Story.Msg -> Model -> UpdateResponse msg
onStory config msg game =
    Update.child
        { get = .story
        , set = (\story game -> { game | story = story })
        , toMsg = StoryMsg >> config.toMsg
        , update = (Story.update game)
        }
        msg
        game


onInventory : Config msg -> Inventory.Msg -> Model -> UpdateResponse msg
onInventory config msg game =
    Update.child
        { get = .inventory
        , set = (\inventory game -> { game | inventory = inventory })
        , toMsg = InventoryMsg >> config.toMsg
        , update = Inventory.update
        }
        msg
        game


onWeb : Config msg -> Web.Msg -> Model -> UpdateResponse msg
onWeb config msg game =
    Update.child
        { get = .web
        , set = (\web game -> { game | web = web })
        , toMsg = WebMsg >> config.toMsg
        , update = (Web.update game)
        }
        msg
        game



-- remember to remove Game.Model after refactoring Game.Servers


onServers : Config msg -> Servers.Msg -> Model -> UpdateResponse msg
onServers config msg model =
    let
        lastTick =
            Meta.getLastTick (getMeta model)

        config_ =
            serversConfig lastTick
                (getFlags model)
                config

        ( servers, cmd, dispatch ) =
            Servers.update config_ msg <| getServers model

        model_ =
            { model | servers = servers }
    in
        ( model_, cmd, dispatch )


onLogFlix : Config msg -> LogFlix.Msg -> Model -> UpdateResponse msg
onLogFlix config msg game =
    Update.child
        { get = .backfeed
        , set = (\backfeed game -> { game | backfeed = backfeed })
        , toMsg = LogFlixMsg >> config.toMsg
        , update = (LogFlix.update game)
        }
        msg
        game



-- requests


updateRequest : Config msg -> Response -> Model -> UpdateResponse msg
updateRequest config response model =
    case response of
        Request.Resync (Resync.Okay data) ->
            uncurry (flip <| onResyncResponse config) data


onResyncResponse :
    Config msg
    -> Decoders.Game.ServersToJoin
    -> Model
    -> UpdateResponse msg
onResyncResponse config servers model =
    let
        dispatch =
            servers.player
                |> List.map (bootstrapJoin servers.remote)
                |> Dispatch.batch
    in
        ( model, Cmd.none, dispatch )



-- events


handleJoinedAccount : Config msg -> Value -> Model -> UpdateResponse msg
handleJoinedAccount config value model =
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
                    Error.porra msg
                        |> Core.Crash
                        |> Dispatch.core
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
        Dispatch.websocket <|
            Ws.Join (ServerChannel cid) Nothing


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
                        Ws.Join channel <|
                            Just payload

            Nothing ->
                Dispatch.none
