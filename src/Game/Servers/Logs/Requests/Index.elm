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
import Game.Servers.Shared as Servers
import Game.Servers.Logs.Messages exposing (..)


type Response
    = Okay Logs


type alias Logs =
    List Log


type alias Log =
    { id : String
    , message : Maybe String
    , insertedAt : Time
    }


request : Servers.ID -> ConfigSource a -> Cmd Msg
request id =
    Requests.request ServerLogIndexTopic
        (IndexRequest >> Request)
        (Just id)
        Encode.null


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Result.map Okay
                |> Result.toMaybe

        _ ->
            -- TODO: handle errors
            Nothing



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
