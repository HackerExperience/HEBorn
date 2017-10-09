module Game.Servers.Filesystem.Requests.Sync
    exposing
        ( Response(..)
        , Index
        , request
        , receive
        , decoder
        )

import Requests.Requests as Requests
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , oneOf
        , map
        , maybe
        , lazy
        , list
        , string
        , int
        )
import Game.Servers.Filesystem.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(SyncRequest)
        )
import Game.Network.Types exposing (NIP)
import Decoders.Filesystem


type alias Index =
    Decoders.Filesystem.Index


type Response
    = Okay Index


request : NIP -> ConfigSource a -> Cmd Msg
request nip =
    Requests.request (Topics.fsSync nip)
        (SyncRequest >> Request)
        emptyPayload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue decoder json
                |> Result.map Okay
                |> Requests.report

        _ ->
            Nothing


decoder : Decoder Decoders.Filesystem.Index
decoder =
    list <| lazy Decoders.Filesystem.entry
