module Game.Servers.Logs.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue, list)
import Dict
import Utils.Update as Update
import Game.Models as Game
import Requests.Requests as Requests
import Game.Servers.Shared as Servers
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ServerEvent), ServerEvent(LogsEvent))
import Events.Servers.Logs as Logs
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Requests.Index as Index
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias LogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Game.Model -> Servers.ID -> Msg -> Model -> UpdateResponse
update game serverId msg model =
    case msg of
        Delete id ->
            onDelete game serverId id model

        Hide id ->
            onHide game serverId id model

        LogMsg id msg ->
            onLogMsg game serverId id msg model

        Event event ->
            onEvent game serverId event model

        Request data ->
            onRequest game serverId (receive data) model


bootstrap : Value -> Model -> Model
bootstrap json model =
    decodeValue Index.decoder json
        |> Requests.report
        |> Maybe.withDefault []
        |> toModel



-- collection message handlers


onDelete : Game.Model -> Servers.ID -> ID -> Model -> UpdateResponse
onDelete game serverId id model =
    Update.fromModel model


onHide : Game.Model -> Servers.ID -> ID -> Model -> UpdateResponse
onHide game serverId id model =
    Update.fromModel model


onEvent : Game.Model -> Servers.ID -> Events.Event -> Model -> UpdateResponse
onEvent game serverId event model =
    let
        msg =
            LogEvent event

        reducer id log ( model, cmd, dispatch ) =
            Update.fromModel log
                |> Update.andThen (updateLog game serverId id msg)
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id)
                |> Update.addCmd cmd
                |> Update.addDispatch dispatch
    in
        Dict.foldl reducer (Update.fromModel model) model
            |> Update.andThen (updateEvent game serverId event)


onRequest : Game.Model -> Servers.ID -> Maybe Response -> Model -> UpdateResponse
onRequest game serverId response model =
    case response of
        Just response ->
            updateRequest game serverId response model

        Nothing ->
            Update.fromModel model


onLogMsg : Game.Model -> Servers.ID -> ID -> LogMsg -> Model -> UpdateResponse
onLogMsg game serverId id msg model =
    case get id model of
        Just log ->
            updateLog game serverId id msg log
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id)

        Nothing ->
            Update.fromModel model


updateEvent :
    Game.Model
    -> Servers.ID
    -> Events.Event
    -> Model
    -> UpdateResponse
updateEvent game serverId event model =
    case event of
        ServersEvent (ServerEvent _ (LogsEvent (Logs.Changed data))) ->
            Update.fromModel (toModel data)

        _ ->
            Update.fromModel model


updateRequest : Game.Model -> Servers.ID -> Response -> Model -> UpdateResponse
updateRequest game serverId response model =
    Update.fromModel model



-- content message handlers


toModel : Index.Index -> Model
toModel index =
    let
        mapper data =
            ( data.id, new data.insertedAt Normal data.message )
    in
        index
            |> List.map mapper
            |> List.foldl (uncurry insert) initialModel


updateLog : Game.Model -> Servers.ID -> ID -> LogMsg -> Log -> LogUpdateResponse
updateLog game serverId id msg log =
    case msg of
        UpdateContent content ->
            onUpdateContent game serverId id content log

        Encrypt ->
            onEncrypt game serverId id log

        Decrypt content ->
            onDecrypt game serverId id content log

        LogRequest data ->
            onLogRequest game serverId id (logReceive data) log

        LogEvent event ->
            updateLogEvent game serverId id event log


onUpdateContent : Game.Model -> Servers.ID -> ID -> String -> Log -> LogUpdateResponse
onUpdateContent game serverId id content log =
    setContent (Just content) log
        |> Update.fromModel


onEncrypt : Game.Model -> Servers.ID -> ID -> Log -> LogUpdateResponse
onEncrypt game serverId id log =
    setContent Nothing log
        |> Update.fromModel


onDecrypt : Game.Model -> Servers.ID -> ID -> String -> Log -> LogUpdateResponse
onDecrypt game serverId id content log =
    setContent (Just content) log
        |> Update.fromModel


onLogRequest :
    Game.Model
    -> Servers.ID
    -> ID
    -> Maybe LogResponse
    -> Log
    -> LogUpdateResponse
onLogRequest game serverId id response log =
    case response of
        Just response ->
            updateLogRequest game serverId id response log

        Nothing ->
            Update.fromModel log


updateLogRequest :
    Game.Model
    -> Servers.ID
    -> ID
    -> LogResponse
    -> Log
    -> LogUpdateResponse
updateLogRequest game serverId id resposne log =
    -- no log responses yet
    Update.fromModel log


updateLogEvent :
    Game.Model
    -> Servers.ID
    -> ID
    -> Events.Event
    -> Log
    -> LogUpdateResponse
updateLogEvent game serverId id event log =
    Update.fromModel log
