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
        , list
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, hardcoded)
import Json.Encode as Encode
import Result exposing (Result(..))
import Core.Config exposing (Config)
import Game.Servers.Messages exposing (..)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (Code(..))


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

    -- , inserted_at : ?
    }


request : Config -> Cmd Msg
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
    -- TODO: add timestamp once format is figured out
    decode Log
        |> required "log_id" string
        |> required "message" string
