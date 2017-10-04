module Game.Requests.Bootstrap
    exposing
        ( Response(..)
        , request
        , receive
        )

import Decoders.Bootstrap
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Game.Messages exposing (..)


type Response
    = Okay Decoders.Bootstrap.Bootstrap


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
                |> decodeValue Decoders.Bootstrap.bootstrap
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing
