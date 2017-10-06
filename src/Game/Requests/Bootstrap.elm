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
import Game.Account.Models as Account


type Response
    = Okay Decoders.Bootstrap.Bootstrap


request : Account.ID -> ConfigSource a -> Cmd Msg
request id =
    Requests.request (Topics.accountBootstrap id)
        (BootstrapRequest >> Request)
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
