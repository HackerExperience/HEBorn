module Game.Servers.Requests.Resync
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
        , RequestMsg(ResyncRequest)
        )
import Game.Servers.Shared exposing (..)


type Response
    = Okay ( CId, Server )


request : Maybe GatewayCache -> CId -> ConfigSource a -> Cmd Msg
request gatewayCache id =
    -- this request is mainly used to fetch invaded computers
    Requests.request (Topics.serverResync id)
        (ResyncRequest gatewayCache id >> Request)
        emptyPayload


receive : Maybe GatewayCache -> CId -> Code -> Value -> Maybe Response
receive gatewayCache id code json =
    case code of
        OkCode ->
            decodeValue (Decoders.Servers.server gatewayCache) json
                |> Result.map ((,) id >> Okay)
                |> Requests.report

        _ ->
            Nothing
