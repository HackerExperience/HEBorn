module Game.Update exposing (update)

import Utils.React as React exposing (React)
import Dict exposing (Dict)
import Set
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Core.Error as Error
import Decoders.Game
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Update as Account
import Game.Bank.Messages as Bank
import Game.Bank.Models as Bank
import Game.Bank.Update as Bank
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
import Game.BackFlix.Messages as BackFlix
import Game.BackFlix.Update as BackFlix
import Game.Meta.Types.Network as Network
import Game.Requests.Resync as ResyncRequest
    exposing
        ( resyncRequest
        , resyncReceive
        )
import Game.Config exposing (..)
import Game.Messages exposing (..)
import Game.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        AccountMsg msg ->
            onAccount config msg model

        BankMsg msg ->
            onBank config msg model

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

        BackFlixMsg msg ->
            onBackFlix config msg model

        Resync ->
            onResync config model

        ResyncRequest response ->
            onResyncRequest config (resyncReceive model response) model

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

        react =
            model
                |> resyncRequest accountId
                |> Cmd.map (ResyncRequest >> config.toMsg)
                |> React.cmd
    in
        ( model, react )



-- childs


onAccount : Config msg -> Account.Msg -> Model -> UpdateResponse msg
onAccount config msg model =
    let
        lastTick =
            Meta.getLastTick (getMeta model)

        config_ =
            accountConfig lastTick (getFlags model) config

        ( account, react ) =
            Account.update config_ msg <| getAccount model

        model_ =
            { model | account = account }
    in
        ( model_, react )


onBank : Config msg -> Bank.Msg -> Model -> UpdateResponse msg
onBank config msg model =
    let
        config_ =
            bankConfig (getAccount model) (getServers model) (getFlags model) config

        ( bank, react ) =
            Bank.update config_ msg <| getBank model

        model_ =
            { model | bank = bank }
    in
        ( model_, react )


onMeta : Config msg -> Meta.Msg -> Model -> UpdateResponse msg
onMeta config msg model =
    let
        config_ =
            metaConfig config

        ( meta, react ) =
            Meta.update config_ msg <| getMeta model

        model_ =
            setMeta meta model
    in
        ( model_, react )


onStory : Config msg -> Story.Msg -> Model -> UpdateResponse msg
onStory config msg model =
    let
        accountId =
            model
                |> getAccount
                |> Account.getId

        config_ =
            storyConfig accountId (getFlags model) config

        ( story, react ) =
            Story.update config_ msg <| getStory model

        model_ =
            setStory story model
    in
        ( model_, react )


onInventory : Config msg -> Inventory.Msg -> Model -> UpdateResponse msg
onInventory config msg model =
    let
        config_ =
            inventoryConfig (getFlags model) config

        ( inventory, react ) =
            Inventory.update config_ msg <| getInventory model

        model_ =
            setInventory inventory model
    in
        ( model_, react )


onWeb : Config msg -> Web.Msg -> Model -> UpdateResponse msg
onWeb config msg model =
    let
        servers =
            getServers model

        config_ =
            webConfig (getFlags model) servers config

        ( web, react ) =
            Web.update config_ msg <| getWeb model

        model_ =
            setWeb web model
    in
        ( model_, react )



-- remember to remove Game.Model after refactoring Game.Servers


onServers : Config msg -> Servers.Msg -> Model -> UpdateResponse msg
onServers config msg model =
    let
        lastTick =
            Meta.getLastTick (getMeta model)

        activeCId =
            model
                |> getActiveServer
                |> Maybe.map Tuple.first

        config_ =
            serversConfig activeCId
                (getGateway model)
                lastTick
                (getFlags model)
                config

        ( servers, react ) =
            Servers.update config_ msg <| getServers model

        model_ =
            setServers servers model
    in
        ( model_, react )


onBackFlix : Config msg -> BackFlix.Msg -> Model -> UpdateResponse msg
onBackFlix config msg model =
    let
        config_ =
            backFlixConfig config

        ( backflix_, react ) =
            BackFlix.update config_ msg <| getBackFlix model

        model_ =
            setBackFlix backflix_ model
    in
        ( model_, react )


onResyncRequest :
    Config msg
    -> ResyncRequest.Data
    -> Model
    -> UpdateResponse msg
onResyncRequest config data model =
    case data of
        Ok ( model, servers ) ->
            ( model
            , servers.player
                |> List.map (bootstrapJoin config servers.remote)
                |> config.batchMsg
                |> React.msg
            )

        Err _ ->
            ( model, React.none )



-- events


handleJoinedAccount : Config msg -> Value -> Model -> UpdateResponse msg
handleJoinedAccount config value model =
    case Decode.decodeValue (Decoders.Game.bootstrap model) value of
        Ok ( model_, servers ) ->
            ( model_
            , servers.player
                |> List.map (bootstrapJoin config servers.remote)
                |> config.batchMsg
                |> React.msg
            )

        Err reason ->
            let
                -- TODO: use a better error reporting function that checks
                -- for development mode
                msg =
                    Debug.log "▶ " ("Bootstrap Error:\n" ++ reason)
            in
                ( model, React.msg <| config.onError (Error.porra msg) )


bootstrapJoin :
    Config msg
    -> Decoders.Game.RemoteServers
    -> Decoders.Game.Player
    -> msg
bootstrapJoin config remoteServers playerServer =
    let
        msg1 =
            joinPlayer config playerServer

        msg2 =
            playerServer.endpoints
                |> Set.toList
                |> List.filterMap
                    (Servers.EndpointCId
                        >> Servers.toSessionId
                        >> flip Dict.get remoteServers
                    )
                |> List.filterMap (joinRemote config playerServer)
                |> config.batchMsg
    in
        config.batchMsg [ msg1, msg2 ]


joinPlayer : Config msg -> Decoders.Game.Player -> msg
joinPlayer config server =
    let
        cid =
            Servers.GatewayCId server.serverId
    in
        config.onJoinServer cid Nothing


joinRemote :
    Config msg
    -> Decoders.Game.Player
    -> Decoders.Game.Remote
    -> Maybe msg
joinRemote config fromServer toServer =
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
                    cid =
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
                    Just <| config.onJoinServer cid (Just payload)

            Nothing ->
                Nothing
