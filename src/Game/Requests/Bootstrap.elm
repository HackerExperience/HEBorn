module Game.Requests.Bootstrap
    exposing
        ( Response(..)
        , Data
        , ServerIndex
        , request
        , receive
        , decoder
        )

import Json.Decode exposing (Decoder, Value, decodeValue, list)
import Json.Decode.Pipeline exposing (decode, required)
import Game.Servers.Requests.Bootstrap
    exposing
        ( GatewayData
        , EndpointData
        , gatewayDecoder
        , endpointDecoder
        )
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Messages exposing (..)


type Response
    = Okay Data


type alias Data =
    { servers :
        ServerIndex
    }


type alias ServerIndex =
    { gateways :
        List GatewayData
    , endpoints :
        List EndpointData
    }


request : String -> ConfigSource a -> Cmd Msg
request account =
    Requests.request Topics.accountBootstrap
        (BootstrapRequest >> Request)
        (Just account)
        emptyPayload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing


decoder : Decoder Data
decoder =
    decode Data
        |> required "servers" serverIndexDecoder



-- internals


serverIndexDecoder : Decoder ServerIndex
serverIndexDecoder =
    decode ServerIndex
        |> required "gateways" (list gatewayDecoder)
        |> required "endpoints" (list endpointDecoder)
