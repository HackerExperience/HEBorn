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
import Game.Network.Types exposing (NIP)


type Response
    = Okay ( ID, Server )


request : Maybe ServerUid -> ID -> ConfigSource a -> Cmd Msg
request serverUid id =
    -- this request is mainly used to fetch invaded computers
    Requests.request (Topics.serverResync id)
        (ResyncRequest serverUid id >> Request)
        emptyPayload


receive : Maybe ServerUid -> ID -> Code -> Value -> Maybe Response
receive serverUid id code json =
    case code of
        OkCode ->
            decodeValue (Decoders.Servers.server serverUid) json
                |> Result.map ((,) id >> Okay)
                |> Requests.report

        _ ->
            Nothing
