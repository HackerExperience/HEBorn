module Game.Servers.Processes.Requests.Bruteforce
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Meta.Types.Network as Network
import Game.Servers.Shared exposing (CId)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BruteforceRequest)
        )


type Response
    = Okay


request :
    ID
    -> Network.ID
    -> Network.IP
    -> CId
    -> FlagsSource a
    -> Cmd Msg
request optimistic network targetIp cid =
    let
        payload =
            Encode.object
                [ ( "network_id", Encode.string <| network )
                , ( "ip", Encode.string <| targetIp )
                , ( "bounces", Encode.list [] )
                ]
    in
        Requests.request (Topics.bruteforce cid)
            (BruteforceRequest optimistic >> Request)
            payload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            Just Okay

        _ ->
            Nothing
