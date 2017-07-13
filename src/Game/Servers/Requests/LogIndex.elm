module Game.Servers.Requests.LogIndex
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode
    exposing
        -- this request contains no payload, so no problems with importing this
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        , andThen
        , list
        , string
        )
import Date exposing (Date)
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..))
import Utils.Json.Decode exposing (date)
import Game.Servers.Messages exposing (..)


type Response
    = OkResponse Logs
    | NoOp


type alias Root =
    { logs : Logs }


type alias Logs =
    List Log


type alias Log =
    { id : String
    , message : String
    , insertedAt : Date
    }


request : ConfigSource a -> Cmd Msg
request =
    Requests.request ServerLogIndexTopic
        (LogIndexRequest >> Request)
        Nothing
        Encode.null


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decoder
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            -- TODO: handle errors
            NoOp



-- internals


decoder : Value -> Result String Logs
decoder json =
    case decodeValue root json of
        Ok root ->
            Ok root.logs

        Err reason ->
            Err reason


root : Decoder Root
root =
    decode Root
        |> required "logs" (list log)


log : Decoder Log
log =
    decode Log
        |> required "log_id" string
        |> required "message" string
        |> required "inserted_at" date
