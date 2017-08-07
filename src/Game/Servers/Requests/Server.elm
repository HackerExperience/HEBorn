module Game.Servers.Requests.Server
    exposing
        ( Response(..)
        , Server
        , receive
        , decoder
        )

import Json.Decode.Pipeline exposing (decode, required)
import Json.Decode exposing (Decoder, Value, decodeValue, list, string, value)
import Requests.Requests as Requests
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)


type Response
    = OkResponse Server
    | NoOp


type alias Server =
    { id : String

    -- this is temporary
    , data : Value
    , logs : Value
    }


receive : Code -> Value -> Response
receive code json =
    case code of
        OkCode ->
            json
                |> decoder
                |> Result.map OkResponse
                |> Requests.report

        _ ->
            NoOp


decoder : Value -> Result String Server
decoder =
    decodeValue response


response : Decoder Server
response =
    decode Server
        |> required "id" string
        |> required "data" value
        |> required "logs" value
