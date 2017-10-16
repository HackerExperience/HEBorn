module Game.Servers.Logs.Update exposing (update)

import Json.Decode exposing (Value, decodeValue, list)
import Dict
import Utils.Update as Update
import Game.Models as Game
import Requests.Requests as Requests
import Game.Servers.Shared as Servers
import Game.Servers.Logs.Messages exposing (..)
import Game.Servers.Logs.Models exposing (..)
import Game.Servers.Logs.Requests exposing (..)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Network.Types exposing (NIP)
import Decoders.Logs


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


type alias LogUpdateResponse =
    ( Log, Cmd LogMsg, Dispatch )


update : Game.Model -> NIP -> Msg -> Model -> UpdateResponse
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


onDelete : Game.Model -> NIP -> ID -> Model -> UpdateResponse
onDelete game nip id model =
    Update.fromModel model


onHide : Game.Model -> NIP -> ID -> Model -> UpdateResponse
onHide game nip id model =
    Update.fromModel model


onRequest : Game.Model -> NIP -> Maybe Response -> Model -> UpdateResponse
onRequest game nip response model =
    case response of
        Just response ->
            updateRequest game nip response model

        Nothing ->
            Update.fromModel model


onLogMsg : Game.Model -> NIP -> ID -> LogMsg -> Model -> UpdateResponse
onLogMsg game nip id msg model =
    case get id model of
        Just log ->
            updateLog game nip id msg log
                |> Update.mapModel (flip (insert id) model)
                |> Update.mapCmd (LogMsg id)

        Nothing ->
            Update.fromModel model


updateRequest : Game.Model -> NIP -> Response -> Model -> UpdateResponse
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


updateLog : Game.Model -> NIP -> ID -> LogMsg -> Log -> LogUpdateResponse
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


onUpdateContent : Game.Model -> NIP -> ID -> String -> Log -> LogUpdateResponse
onUpdateContent game nip id content log =
    setContent (Just content) log
        |> Update.fromModel


onEncrypt : Game.Model -> NIP -> ID -> Log -> LogUpdateResponse
onEncrypt game nip id log =
    setContent Nothing log
        |> Update.fromModel


onDecrypt : Game.Model -> NIP -> ID -> String -> Log -> LogUpdateResponse
onDecrypt game nip id content log =
    setContent (Just content) log
        |> Update.fromModel


onLogRequest :
    Game.Model
    -> NIP
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
    -> NIP
    -> ID
    -> LogResponse
    -> Log
    -> LogUpdateResponse
updateLogRequest game nip id resposne log =
    -- no log responses yet
    Update.fromModel log
