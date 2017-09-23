module Game.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Dict
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Reports as Ws
import Events.Events as Events
import Json.Encode as Encode
import Game.Account.Messages as Account
import Game.Account.Models as Account
import Game.Account.Update as Account
import Game.Meta.Messages as Meta
import Game.Meta.Update as Meta
import Game.Servers.Messages as Servers
import Game.Servers.Models as Servers
import Game.Servers.Update as Servers
import Game.Storyline.Messages as Story
import Game.Storyline.Update as Story
import Game.Web.Messages as Web
import Game.Web.Update as Web
import Game.Messages exposing (..)
import Game.Models exposing (..)
import Game.Requests exposing (..)
import Game.Requests.Bootstrap as Bootstrap
import Game.Servers.Requests.Bootstrap as ServerBootstrap


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
            onWebMsg msg model

        Event data ->
            onEvent data model

        Request data ->
            onRequest (receive data) model

        _ ->
            Update.fromModel model



-- internals


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


onWebMsg : Web.Msg -> Model -> UpdateResponse
onWebMsg msg model =
    Web.update model msg
        |> uncurry ((,,) model)
        |> Update.mapCmd WebMsg


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


onEvent : Events.Event -> Model -> UpdateResponse
onEvent event model =
    onAccount (Account.Event event) model
        |> Update.andThen (onMeta (Meta.Event event))
        |> Update.andThen (onServers (Servers.Event event))
        |> Update.andThen (onStory (Story.Event event))
        |> Update.andThen (updateEvent event)


onRequest : Maybe Response -> Model -> UpdateResponse
onRequest response model =
    case response of
        Just response ->
            updateRequest response model

        Nothing ->
            Update.fromModel model


updateEvent : Events.Event -> Model -> UpdateResponse
updateEvent event model =
    case event of
        Events.Report (Ws.Connected _) ->
            onWsConnected model

        Events.Report (Ws.Joined AccountChannel) ->
            onWsJoinedAccount model

        _ ->
            Update.fromModel model


updateRequest : Response -> Model -> UpdateResponse
updateRequest response model =
    case response of
        Bootstrap (Bootstrap.Okay data) ->
            onBootstrapResponse data model


onWsConnected : Model -> UpdateResponse
onWsConnected model =
    let
        dispatch =
            Dispatch.websocket (Ws.JoinChannel RequestsChannel Nothing Nothing)
    in
        ( model, Cmd.none, dispatch )


onWsJoinedAccount : Model -> UpdateResponse
onWsJoinedAccount model =
    let
        request =
            Bootstrap.request model.account.id model
    in
        -- replace Cmd.none to request to enable bootstrap
        ( model, request, Dispatch.none )


onBootstrapResponse : Bootstrap.Data -> Model -> UpdateResponse
onBootstrapResponse data model =
    let
        gateways =
            List.map .id data.servers.gateways

        activeServer =
            List.head gateways

        account_ =
            List.foldl Account.insertServer
                model.account
                gateways

        insertServer toServerUnion generic servers =
            let
                server =
                    ServerBootstrap.toServer <| toServerUnion generic
            in
                Servers.insert generic.id server servers

        serversWithGateways =
            List.foldl (insertServer ServerBootstrap.GatewayServer)
                model.servers
                data.servers.gateways

        servers_ =
            List.foldl (insertServer ServerBootstrap.EndpointServer)
                serversWithGateways
                data.servers.endpoints

        model_ =
            { model
                | account = account_
                , servers = servers_
                , story = data.story
            }

        joinServer gatewayId list =
            -- TODO: include endpoint join
            let
                context =
                    Just gatewayId

                payload =
                    Just <|
                        Encode.object
                            [ ( "gateway_id", Encode.string gatewayId )
                            ]

                dispatch =
                    Dispatch.websocket <|
                        Ws.JoinChannel ServerChannel context payload
            in
                dispatch :: list

        dispatch =
            gateways
                |> List.foldl joinServer []
                |> Dispatch.batch
    in
        ( model_, Cmd.none, dispatch )
