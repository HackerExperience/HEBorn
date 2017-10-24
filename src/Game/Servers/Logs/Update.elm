module Game.Servers.Logs.Update exposing (update)

import Utils.Update as Update
import Game.Models as Game
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Network.Types exposing (NIP)
import Game.Servers.Shared exposing (CId)
import Decoders.Logs


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias LogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Game.Model -> CId -> Msg -> Model -> UpdateResponse
update game nip msg model =
    case msg of
        Delete id ->
            onDelete game nip id model

        Hide id ->
            onHide game nip id model

        LogMsg id msg ->
            onLogMsg game nip id msg model

        Request data ->
            onRequest game nip (receive data) model



-- collection message handlers


onDelete : Game.Model -> CId -> ID -> Model -> UpdateResponse
onDelete game nip id model =
    Update.fromModel model


onHide : Game.Model -> CId -> ID -> Model -> UpdateResponse
onHide game nip id model =
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


updateRequest : Game.Model -> CId -> Response -> Model -> UpdateResponse
updateRequest game nip response model =
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


updateLog : Game.Model -> CId -> ID -> LogMsg -> Log -> LogUpdateResponse
updateLog game nip id msg log =
    case msg of
        UpdateContent content ->
            onUpdateContent game nip id content log

        Encrypt ->
            onEncrypt game nip id log

        Decrypt content ->
            onDecrypt game nip id content log

        LogRequest data ->
            onLogRequest game nip id (logReceive data) log


onUpdateContent : Game.Model -> CId -> ID -> String -> Log -> LogUpdateResponse
onUpdateContent game nip id content log =
    setContent (Just content) log
        |> Update.fromModel


onEncrypt : Game.Model -> CId -> ID -> Log -> LogUpdateResponse
onEncrypt game nip id log =
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
