module Game.BackFlix.Models exposing (..)

import Dict exposing (Dict)
import Time exposing (Time)
import Json.Decode exposing (Value)
import Core.Error as Error


type alias Model =
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
    Dict.empty


insert : Log -> Model -> Model
insert log model =
    let
        log_id =
            (findId ( log.timestamp, 0 ) model)
    in
        Dict.insert log_id log model



-- FIXME: these functions should affect model, not the Model Type


findId : ( Time, Int ) -> Model -> Id
findId (( birth, from ) as pig) backflix =
    backflix
        |> Dict.get pig
        |> Maybe.map (\twin -> findId ( birth, from + 1 ) backflix)
        |> Maybe.withDefault pig


remove : Id -> Model -> Model
remove =
    Dict.remove


member : Id -> Model -> Bool
member =
    Dict.member


get : Id -> Model -> Maybe Log
get =
    Dict.get


filter : (Id -> Log -> Bool) -> Model -> Model
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
