module Game.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
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
import Game.Web.Messages as Web
import Game.Web.Update as Web
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
            updateAccount msg model

        ServersMsg msg ->
            updateServers msg model

        MetaMsg msg ->
            updateMeta msg model

        WebMsg msg ->
            updateWeb msg model

        Event data ->
            Update.andThen (updateEvent data) (broadcastEvent data model)

        Request data ->
            updateResponse (receive data) model

        _ ->
            Update.fromModel model



-- internals


broadcastEvent : Events.Event -> Model -> UpdateResponse
broadcastEvent event model =
    updateAccount (Account.Event event) model
        |> Update.andThen (updateMeta (Meta.Event event))
        |> Update.andThen (updateWeb (Web.Event event))
        |> Update.andThen (updateServers (Servers.Event event))


updateAccount : Account.Msg -> Model -> UpdateResponse
updateAccount msg game =
    Update.child
        { get = .account
        , set = (\account game -> { game | account = account })
        , toMsg = AccountMsg
        , update = (Account.update game)
        }
        msg
        game


updateMeta : Meta.Msg -> Model -> UpdateResponse
updateMeta msg game =
    Update.child
        { get = .meta
        , set = (\meta game -> { game | meta = meta })
        , toMsg = MetaMsg
        , update = (Meta.update game)
        }
        msg
        game


updateWeb : Web.Msg -> Model -> UpdateResponse
updateWeb msg game =
    Update.child
        { get = .web
        , set = (\web game -> { game | web = web })
        , toMsg = WebMsg
        , update = (Web.update game)
        }
        msg
        game


updateServers : Servers.Msg -> Model -> UpdateResponse
updateServers msg game =
    Update.child
        { get = .servers
        , set = (\servers game -> { game | servers = servers })
        , toMsg = ServersMsg
        , update = (Servers.update game)
        }
        msg
        game


updateEvent : Events.Event -> Model -> UpdateResponse
updateEvent event model =
    case event of
        Events.Report (Ws.Connected _) ->
            eventWsConnected model

        Events.Report (Ws.Joined AccountChannel) ->
            eventWsJoinedAccount model

        _ ->
            Update.fromModel model


updateResponse : Response -> Model -> UpdateResponse
updateResponse response model =
    case response of
        BootstrapResponse (Bootstrap.OkResponse data) ->
            onBootstrapResponse data model

        _ ->
            Update.fromModel model


eventWsConnected : Model -> UpdateResponse
eventWsConnected model =
    let
        dispatch =
            Dispatch.websocket (Ws.JoinChannel RequestsChannel Nothing)
    in
        ( model, Cmd.none, dispatch )


eventWsJoinedAccount : Model -> UpdateResponse
eventWsJoinedAccount model =
    let
        request =
            Bootstrap.request model.account.id model
    in
        -- replace Cmd.none to request to enable bootstrap
        ( model, Cmd.none, Dispatch.none )


onBootstrapResponse : Bootstrap.Data -> Model -> UpdateResponse
onBootstrapResponse data model =
    -- TODO: propagate change
    updateServers (Servers.Bootstrap data.servers) model
