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
import Decoders.Process
import Game.Network.Types exposing (NIP)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BruteforceRequest)
        )


type Response
    = Okay ID Process


request : ID -> ID -> ID -> ConfigSource a -> Cmd Msg
request optimistic target origin =
    let
        payload =
            Encode.object
                [ ( "target", Encode.string target )
                ]
    in
        Requests.request Topics.bruteforce
            (BruteforceRequest optimistic >> Request)
            (Just origin)
            payload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue Decoders.Process.process json
                |> Result.map (uncurry Okay)
                |> Requests.report

        _ ->
            Nothing
