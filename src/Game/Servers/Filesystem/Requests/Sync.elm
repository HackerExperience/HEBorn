module Game.Servers.Filesystem.Requests.Sync
    exposing
        ( Response(..)
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
        , lazy
        , list
        )
import Game.Servers.Filesystem.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(SyncRequest)
        )
import Game.Network.Types exposing (NIP)
import Game.Servers.Filesystem.Shared exposing (Foreigners)
import Decoders.Filesystem exposing (entry)


type Response
    = Okay Foreigners


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


decoder : Decoder Foreigners
decoder =
    list <| lazy entry
