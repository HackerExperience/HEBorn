module Game.Servers.Processes.Requests.Bruteforce
    exposing
        ( Response(..)
        , Data
        , request
        , receive
        , decoder
        )

import Json.Encode as Encode
import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , list
        , string
        , float
        , index
        , value
        )
import Json.Decode.Pipeline exposing (decode, required, optional)
import Events.Servers exposing (ID)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Network.Types exposing (NIP)
import Game.Servers.Processes.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BruteforceRequest)
        )


type Response
    = Okay ID Data


type alias Data =
    { processId : String
    , networkId : String
    , targetIp : String
    , fileId : String
    , connectionId : String
    , type_ : String
    }


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


receive : ID -> Code -> Value -> Maybe Response
receive optimistic code json =
    case code of
        OkCode ->
            decodeValue decoder json
                |> Result.map (Okay optimistic)
                |> Requests.report

        _ ->
            Nothing


decoder : Decoder Data
decoder =
    decode Data
        |> required "process_id" string
        |> required "network_id" string
        |> required "target_ip" string
        |> required "file_id" string
        |> required "connection_id" string
        |> required "type" string
