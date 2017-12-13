module Game.LogStream.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Json.Decode exposing (Value)
import Core.Error as Error


type alias Model =
    { logs : LogStream }


type alias LogStream =
    Dict Id Log


type alias Id =
    ( Time, Int )


type alias Data =
    Value


type Type
    = None
    | Error
    | Join
    | JoinAccount
    | JoinServer
    | Request
    | Receive
    | Event
    | Other


type alias Log =
    { type_ : Type
    , data : Data
    , timestamp : Time
    , typeString : String
    }


initialModel : Model
initialModel =
    { logs = Dict.empty }


insertLog : Log -> Model -> Model
insertLog log model =
    let
        log_id =
            (findId ( log.timestamp, 0 ) model.logs)

        logs_ =
            Dict.insert log_id log model.logs

        model_ =
            { model | logs = logs_ }
    in
        model_


findId : ( Time, Int ) -> LogStream -> Id
findId (( birth, from ) as pig) backfeed =
    backfeed
        |> Dict.get pig
        |> Maybe.map (\twin -> findId ( birth, from + 1 ) backfeed)
        |> Maybe.withDefault pig


remove : Id -> LogStream -> LogStream
remove =
    Dict.remove


member : Id -> LogStream -> Bool
member =
    Dict.member


get : Id -> LogStream -> Maybe Log
get =
    Dict.get


filter : (Id -> Log -> Bool) -> LogStream -> LogStream
filter =
    Dict.filter


getType : String -> Type
getType type_ =
    case type_ of
        "none" ->
            None

        "join" ->
            Join

        "join_account" ->
            JoinAccount

        "join_server" ->
            JoinServer

        "error" ->
            Error

        "event" ->
            Event

        "request" ->
            Request

        "receive" ->
            Receive

        "other" ->
            Other

        _ ->
            "Unexpected type"
                |> Error.porra
                |> uncurry Native.Panic.crash


getByTypeKey : Type -> String
getByTypeKey type_ =
    case type_ of
        None ->
            "none"

        Event ->
            "event"

        Join ->
            "join"

        JoinAccount ->
            "join_account"

        JoinServer ->
            "join_server"

        Error ->
            "error"

        Request ->
            "request"

        Receive ->
            "receive"

        Other ->
            "other"


getTimestamp : Log -> Time
getTimestamp =
    .timestamp


isSimpleWebLog : Log -> Bool
isSimpleWebLog log =
    log.type_ /= Other


getWebLogType : Log -> Type
getWebLogType =
    .type_


getWebLogData : Log -> Data
getWebLogData =
    .data


getWebLogTime : Log -> Time
getWebLogTime =
    .timestamp
