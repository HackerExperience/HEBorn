module Game.Requests.Bootstrap
    exposing
        ( Response(..)
        , Data
        , request
        , receive
        )

import Json.Decode exposing (Decoder, Value, decodeValue, value)
import Json.Decode.Pipeline exposing (decode, required)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Messages exposing (..)


type Response
    = Okay Data


type alias Data =
    { account : Value
    , meta : Value
    , servers : Value
    }


request : String -> ConfigSource a -> Cmd Msg
request account =
    Requests.request AccountBootstrapTopic
        (BootstrapRequest >> Request)
        (Just account)
        emptyPayload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decoder
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing



-- internals


decoder : Value -> Result String Data
decoder =
    decodeValue response


response : Decoder Data
response =
    decode Data
        |> required "account" value
        |> required "meta" value
        |> required "servers" value
