module Game.Servers.Requests.Bootstrap
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Decoders.Servers
import Game.Servers.Models exposing (..)
import Game.Servers.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BootstrapRequest)
        )
import Game.Servers.Shared exposing (..)
import Game.Network.Types exposing (NIP)


type Response
    = Okay ( ID, Server )


request : NIP -> ConfigSource a -> Cmd Msg
request nip =
    -- this request is mainly used to fetch invaded computers
    Requests.request (Topics.serverBootstrap nip)
        (BootstrapRequest >> Request)
        emptyPayload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue Decoders.Servers.serverWithId json
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing
