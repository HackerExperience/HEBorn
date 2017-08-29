module Game.Servers.Requests.Bootstrap
    exposing
        ( Response(..)
        , Server
        , request
        , receive
        , decoder
        )

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
import Json.Decode.Pipeline exposing (decode, required)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(ServerBoostrapTopic))
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)
import Events.Servers exposing (ID, Name, Coordinates)
import Game.Network.Types exposing (NIP, decodeNip)
import Game.Servers.Messages
    exposing
        ( Msg(Request)
        , RequestMsg(BootstrapRequest)
        )


type Response
    = Okay Server


type alias Server =
    { id : ID
    , name : Name
    , coordinates : Coordinates
    , nip : NIP
    , nips : List NIP

    -- TODO: remove Values, use the decoder directly :)
    , logs : Value
    , tunnels : Value
    , filesystem : Value
    , processes : Value
    , meta : Value
    }


request : ID -> ConfigSource a -> Cmd Msg
request id =
    -- this request is mainly used to fetch invaded computers
    Requests.request ServerBoostrapTopic
        (BootstrapRequest >> Request)
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


decoder : Decoder Server
decoder =
    decode Server
        |> required "id" string
        |> required "name" string
        |> required "coordinates" float
        |> required "nip" decodeNip
        |> required "nips" (list decodeNip)
        |> required "logs" value
        |> required "tunnels" value
        |> required "filesystem" value
        |> required "processes" value
        |> required "meta" value
