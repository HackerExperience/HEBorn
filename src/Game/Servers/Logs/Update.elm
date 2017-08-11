module Game.Servers.Logs.Update exposing (update, bootstrap)

import Json.Decode exposing (Value, decodeValue, list)
import Dict
import Utils.Update as Update
import Game.Models as Game
import Events.Events as Events
import Game.Servers.Logs.Messages as Logs exposing (..)
import Game.Servers.Logs.Requests.Index as Index
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias LogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        Delete id ->
            onDelete game id model

        Hide id ->
            onHide game id model

        LogMsg id msg ->
            onLogMsg game id msg model

        Event event ->
            onEvent game event model

        Request data ->
            updateRequest game (receive data) model


bootstrap : Value -> Model -> Model
bootstrap json model =
    let
        mapper data =
            ( data.id, new data.insertedAt Normal data.message )
    in
        decodeValue Index.decoder json
            |> Result.withDefault []
            |> List.map mapper
            |> List.foldl (uncurry insert) model



-- collection message handlers


onDelete : Game.Model -> ID -> Model -> UpdateResponse
onDelete game id model =
    Update.fromModel model


onHide : Game.Model -> ID -> Model -> UpdateResponse
onHide game id model =
    Update.fromModel model


onEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
onEvent game event model =
    let
        msg =
            LogEvent event

        reducer id log ( model, cmd, dispatch ) =
            Update.fromModel log
                |> Update.andThen (updateLog game id msg)
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id)
                |> Update.addCmd cmd
                |> Update.addDispatch dispatch
    in
        Dict.foldl reducer (Update.fromModel model) model
            |> Update.andThen (updateEvent game event)


onLogMsg : Game.Model -> ID -> LogMsg -> Model -> UpdateResponse
onLogMsg game id msg model =
    case get id model of
        Just log ->
            updateLog game id msg log
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id)

        Nothing ->
            Update.fromModel model


updateEvent : Game.Model -> Events.Event -> Model -> UpdateResponse
updateEvent game event model =
    Update.fromModel model


updateRequest : Game.Model -> Response -> Model -> UpdateResponse
updateRequest game data model =
    Update.fromModel model



-- content message handlers


updateLog : Game.Model -> ID -> LogMsg -> Log -> LogUpdateResponse
updateLog game id msg log =
    case msg of
        UpdateContent content ->
            onUpdateContent game id content log

        Encrypt ->
            onEncrypt game id log

        Decrypt content ->
            onDecrypt game id content log

        LogRequest data ->
            updateLogRequest game id (logReceive data) log

        LogEvent event ->
            updateLogEvent game id event log


onUpdateContent : Game.Model -> ID -> String -> Log -> LogUpdateResponse
onUpdateContent game id content log =
    setContent (Just content) log
        |> Update.fromModel


onEncrypt : Game.Model -> ID -> Log -> LogUpdateResponse
onEncrypt game id log =
    setContent Nothing log
        |> Update.fromModel


onDecrypt : Game.Model -> ID -> String -> Log -> LogUpdateResponse
onDecrypt game id content log =
    setContent (Just content) log
        |> Update.fromModel


updateLogRequest : Game.Model -> ID -> LogResponse -> Log -> LogUpdateResponse
updateLogRequest game id resposne log =
    -- no log responses yet
    Update.fromModel log


updateLogEvent : Game.Model -> ID -> Events.Event -> Log -> LogUpdateResponse
updateLogEvent game id event log =
    -- no log event responses yet
    Update.fromModel log
