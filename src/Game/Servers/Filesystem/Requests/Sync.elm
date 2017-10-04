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
import Decoders.Filesystem


type alias Index =
    Decoders.Filesystem.Index


type alias ServerID =
    String


type Response
    = Okay Index


request : ServerID -> ConfigSource a -> Cmd Msg
request id =
    Requests.request Topics.fsSync
        (SyncRequest >> Request)
        (Just id)
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
