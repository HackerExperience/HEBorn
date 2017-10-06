module Game.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Dict
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Reports as Ws
import Events.Events as Events
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
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
import Game.Requests as Request exposing (Response)
import Game.Requests.Resync as Resync
import Game.Network.Types as Network
import Decoders.Game exposing (ServerToJoin(..))


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

        Event data ->
            onEvent data model

        Resync ->
            onResync model

        Request data ->
            onRequest (Request.receive model data) model



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


onEvent : Events.Event -> Model -> UpdateResponse
onEvent event model =
    onAccount (Account.Event event) model
        |> Update.andThen (onMeta (Meta.Event event))
        |> Update.andThen (onServers (Servers.Event event))
        |> Update.andThen (onStory (Story.Event event))
        |> Update.andThen (onWeb (Web.Event event))
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

        Events.Report (Ws.Joined (AccountChannel _) bootstrap) ->
            onWsJoinedAccount bootstrap model

        _ ->
            Update.fromModel model


updateRequest : Response -> Model -> UpdateResponse
updateRequest response model =
    case response of
        Request.Resync (Resync.Okay data) ->
            uncurry (flip onResyncResponse) data


onWsConnected : Model -> UpdateResponse
onWsConnected model =
    let
        dispatch =
            Dispatch.websocket (Ws.JoinChannel RequestsChannel Nothing)
    in
        ( model, Cmd.none, dispatch )


onResync : Model -> UpdateResponse
onResync model =
    Update.fromModel model


onWsJoinedAccount : Value -> Model -> UpdateResponse
onWsJoinedAccount value model =
    case Decode.decodeValue (Decoders.Game.bootstrap model) value of
        Ok ( model_, servers ) ->
            let
                dispatch =
                    joinChannel servers
            in
                ( model_, Cmd.none, dispatch )

        Err reason ->
            let
                log =
                    Debug.log ("▶ Bootstrap Error:\n" ++ reason) ""
            in
                Update.fromModel model


joinChannel : Decoders.Game.ServersToJoin -> Dispatch
joinChannel servers =
    let
        toId data =
            Network.toNip data.networkId data.ip

        encodeGateway data =
            Encode.object
                [ ( "gateway_ip", Encode.string data.ip )
                ]

        encodeEndpoint data =
            Encode.object
                [ ( "password", Encode.string data.password ) ]

        toDispatch server =
            let
                ( channel, payload ) =
                    case server of
                        JoinPlayer data ->
                            ( ServerChannel <| toId data
                            , encodeGateway data
                            )

                        JoinRemote data ->
                            ( ServerChannel <| toId data
                            , encodeEndpoint data
                            )
            in
                Dispatch.websocket <| Ws.JoinChannel channel <| Just payload
    in
        servers
            |> List.map toDispatch
            |> Dispatch.batch


onResyncResponse : Decoders.Game.ServersToJoin -> Model -> UpdateResponse
onResyncResponse servers model =
    let
        dispatch =
            joinChannel servers
    in
        ( model, Cmd.none, dispatch )
