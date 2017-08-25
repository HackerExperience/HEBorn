module Game.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Dict
import Driver.Websocket.Channels exposing (..)
import Driver.Websocket.Messages as Ws
import Driver.Websocket.Reports as Ws
import Events.Events as Events
import Game.Account.Messages as Account
import Game.Account.Update as Account
import Game.Meta.Messages as Meta
import Game.Meta.Update as Meta
import Game.Servers.Messages as Servers
import Game.Servers.Update as Servers
import Game.Storyline.Messages as Story
import Game.Storyline.Update as Story
import Game.Messages exposing (..)
import Game.Models exposing (..)
import Game.Requests exposing (..)
import Game.Requests.Bootstrap as Bootstrap


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
            Dispatch.websocket (Ws.JoinChannel RequestsChannel Nothing)
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
    -- TODO: propagate change
    onServers (Servers.Bootstrap data.servers) model
        |> joinActiveServer


joinActiveServer : UpdateResponse -> UpdateResponse
joinActiveServer (( model, _, _ ) as response) =
    let
        maybeId =
            model.servers.servers
                |> Dict.keys
                |> List.head
    in
        case maybeId of
            Just id ->
                Update.addDispatch
                    (Dispatch.websocket
                        (Ws.JoinChannel ServerChannel <| Just id)
                    )
                    response

            Nothing ->
                response
