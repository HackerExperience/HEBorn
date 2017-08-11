module Game.Servers.Logs.Requests.Index
    exposing
        ( Response(..)
        , request
        , receive
        , decoder
        )

import Json.Decode
    exposing
        -- this request contains no payload, so no problems with importing this
        ( Decoder
        , Value
        , decodeValue
        , list
        , maybe
        , string
        , float
        )
import Time exposing (Time)
import Json.Decode.Pipeline exposing (decode, required)
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Logs.Messages exposing (..)


type Response
    = OkResponse Logs
    | NoOp


type alias Logs =
    List Log


type alias Log =
    { id : String
    , message : Maybe String
    , insertedAt : Time
    }


request : ConfigSource a -> Cmd Msg
request =
    Requests.request ServerLogIndexTopic
        (IndexRequest >> Request)
        Nothing
        Encode.null


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            -- TODO: handle errors
            NoOp



-- internals


decoder : Decoder Logs
decoder =
    list log


log : Decoder Log
log =
    decode Log
        |> required "log_id" string
        |> required "message" (maybe string)
        |> required "inserted_at" float
