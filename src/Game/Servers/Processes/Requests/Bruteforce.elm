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
import Requests.Types exposing (ConfigSource, Code(..))
import Decoders.Processes
import Game.Network.Types as Network
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BruteforceRequest)
        )


type Response
    = Okay ID Process


request :
    ID
    -> Network.NIP
    -> Network.IP
    -> ConfigSource a
    -> Cmd Msg
request optimistic nip targetIp =
    let
        network =
            Network.getId nip

        payload =
            Encode.object
                [ ( "network_id", Encode.string <| network )
                , ( "ip", Encode.string <| targetIp )
                , ( "bounces", Encode.list [] )
                ]
    in
        Requests.request (Topics.bruteforce nip)
            (BruteforceRequest optimistic >> Request)
            payload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue Decoders.Processes.process json
                |> Result.map (uncurry Okay)
                |> Requests.report

        _ ->
            Nothing
