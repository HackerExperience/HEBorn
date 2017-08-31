module Game.Servers.Requests.Bruteforce
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
import Game.Servers.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BruteforceRequest)
        )


type Response
    = Okay Data


type alias Data =
    { processId : String
    , networkId : String
    , targetIp : String
    , fileId : String
    , connectionId : String
    , type_ : String
    }


request : ID -> ID -> ConfigSource a -> Cmd Msg
request target origin =
    let
        payload =
            Encode.object
                [ ( "target", Encode.string target )
                ]
    in
        Requests.request Topics.bruteforce
            (BruteforceRequest >> Request)
            (Just origin)
            payload


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue decoder json
                |> Result.map Okay
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
        -- TODO: add union type here
        |> required "type" string
