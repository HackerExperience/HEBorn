module Events.Account.PasswordAcquired exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , map
        , andThen
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Events.Types exposing (Handler)
import Game.Network.Types exposing (NIP)


type alias Data =
    { nip : NIP
    , password : String
    , processId : String
    , gatewayIp : String
    }


handler : Handler Data event
handler event =
    decodeValue passwordAcquired >> Result.map event



-- internals


passwordAcquired : Decoder Data
passwordAcquired =
    decode Data
        |> custom nip
        |> required "password" string
        |> required "process_id" string
        |> required "gateway_ip" string


nip : Decoder NIP
nip =
    decode (,)
        |> required "network_id" string
        |> required "server_ip" string
