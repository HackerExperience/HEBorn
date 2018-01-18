module Game.Servers.Logs.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Decoders.Logs
import Game.Servers.Logs.Config exposing (..)
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


type alias LogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        HandleDelete id ->
            handleDelete config id model

        HandleHide id ->
            handleHide config id model

        LogMsg id msg ->
            onLogMsg config id msg model

        Request data ->
            onRequest config data model

        HandleCreated id log ->
            onCreated config id log model



-- collection message handlers


handleDelete : Config msg -> ID -> Model -> UpdateResponse msg
handleDelete config id model =
    Update.fromModel model


handleHide : Config msg -> ID -> Model -> UpdateResponse msg
handleHide config id model =
    Update.fromModel model


onRequest : Config msg -> RequestMsg -> Model -> UpdateResponse msg
onRequest config data model =
    let
        response =
            receive data
    in
        case response of
            Just response ->
                updateRequest config response model

            Nothing ->
                Update.fromModel model


onLogMsg : Config msg -> ID -> LogMsg -> Model -> UpdateResponse msg
onLogMsg config id msg model =
    case get id model of
        Just log ->
            updateLog config id msg log
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id >> config.toMsg)

        Nothing ->
            Update.fromModel model


onCreated : Config msg -> ID -> Log -> Model -> UpdateResponse msg
onCreated config id log model =
    model
        |> insert id log
        |> Update.fromModel


updateRequest : Config msg -> Response -> Model -> UpdateResponse msg
updateRequest config response model =
    Update.fromModel model



-- content message handlers


toModel : Decoders.Logs.Index -> Model
toModel index =
    let
        mapper ( id, log ) =
            ( id, log )
    in
        index
            |> List.map mapper
            |> List.foldl (uncurry insert) initialModel


updateLog : Config msg -> ID -> LogMsg -> Log -> LogUpdateResponse
updateLog config id msg log =
    case msg of
        HandleUpdateContent content ->
            handleUpdateContent config id content log

        HandleEncrypt ->
            handleEncrypt config id log

        Decrypt content ->
            onDecrypt config id content log

        LogRequest data ->
            onLogRequest config id data log


handleUpdateContent :
    Config msg
    -> ID
    -> String
    -> Log
    -> LogUpdateResponse
handleUpdateContent config id content log =
    setContent (Just content) log
        |> Update.fromModel


handleEncrypt : Config msg -> ID -> Log -> LogUpdateResponse
handleEncrypt config id log =
    setContent Nothing log
        |> Update.fromModel


onDecrypt : Config msg -> ID -> String -> Log -> LogUpdateResponse
onDecrypt config id content log =
    setContent (Just content) log
        |> Update.fromModel


onLogRequest :
    Config msg
    -> ID
    -> LogRequestMsg
    -> Log
    -> LogUpdateResponse
onLogRequest config id data log =
    let
        response =
            logReceive data
    in
        case response of
            Just response ->
                updateLogRequest config id response log

            Nothing ->
                Update.fromModel log


updateLogRequest :
    Config msg
    -> ID
    -> LogResponse
    -> Log
    -> LogUpdateResponse
updateLogRequest config id resposne log =
    -- no log responses yet
    Update.fromModel log
