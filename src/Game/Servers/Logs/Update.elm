module Game.Servers.Logs.Update exposing (update)

import Utils.Update as Update
import Game.Models as Game
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Servers.Shared exposing (CId)
import Decoders.Logs


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias LogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Game.Model -> CId -> Msg -> Model -> UpdateResponse
update game nip msg model =
    case msg of
        HandleDelete id ->
            handleDelete game nip id model

        HandleHide id ->
            handleHide game nip id model

        LogMsg id msg ->
            onLogMsg game nip id msg model

        Request data ->
            onRequest game nip (receive data) model

        HandleCreated id log ->
            onCreated game nip id log model



-- collection message handlers


handleDelete : Game.Model -> CId -> ID -> Model -> UpdateResponse
handleDelete game nip id model =
    Update.fromModel model


handleHide : Game.Model -> CId -> ID -> Model -> UpdateResponse
handleHide game nip id model =
    Update.fromModel model


onRequest : Game.Model -> CId -> Maybe Response -> Model -> UpdateResponse
onRequest game nip response model =
    case response of
        Just response ->
            updateRequest game nip response model

        Nothing ->
            Update.fromModel model


onLogMsg : Game.Model -> CId -> ID -> LogMsg -> Model -> UpdateResponse
onLogMsg game nip id msg model =
    case get id model of
        Just log ->
            updateLog game nip id msg log
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id)

        Nothing ->
            Update.fromModel model


onCreated : Game.Model -> CId -> ID -> Log -> Model -> UpdateResponse
onCreated game nip id log model =
    model
        |> insert id log
        |> Update.fromModel


updateRequest : Game.Model -> CId -> Response -> Model -> UpdateResponse
updateRequest game nip response model =
    Update.fromModel model



-- content message handlers


updateLog : Game.Model -> CId -> ID -> LogMsg -> Log -> LogUpdateResponse
updateLog game nip id msg log =
    case msg of
        HandleUpdateContent content ->
            handleUpdateContent game nip id content log

        HandleEncrypt ->
            handleEncrypt game nip id log

        Decrypt content ->
            onDecrypt game nip id content log

        LogRequest data ->
            onLogRequest game nip id (logReceive data) log


handleUpdateContent :
    Game.Model
    -> CId
    -> ID
    -> String
    -> Log
    -> LogUpdateResponse
handleUpdateContent game nip id content log =
    setContent (Just content) log
        |> Update.fromModel


handleEncrypt : Game.Model -> CId -> ID -> Log -> LogUpdateResponse
handleEncrypt game nip id log =
    setContent Nothing log
        |> Update.fromModel


onDecrypt : Game.Model -> CId -> ID -> String -> Log -> LogUpdateResponse
onDecrypt game nip id content log =
    setContent (Just content) log
        |> Update.fromModel


onLogRequest :
    Game.Model
    -> CId
    -> ID
    -> Maybe LogResponse
    -> Log
    -> LogUpdateResponse
onLogRequest game nip id response log =
    case response of
        Just response ->
            updateLogRequest game nip id response log

        Nothing ->
            Update.fromModel log


updateLogRequest :
    Game.Model
    -> CId
    -> ID
    -> LogResponse
    -> Log
    -> LogUpdateResponse
updateLogRequest game nip id resposne log =
    -- no log responses yet
    Update.fromModel log
