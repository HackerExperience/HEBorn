module Events.Account.Handlers.ServerPasswordAcquired exposing (Data, handler)

import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , map
        , andThen
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Events.Shared exposing (Handler)
import Game.Meta.Types.Network exposing (NIP)


type alias Data =
    { nip : NIP
    , password : String
    }


handler : Handler Data msg
handler toMsg =
    decodeValue passwordAcquired >> Result.map toMsg



-- internals


passwordAcquired : Decoder Data
passwordAcquired =
    decode Data
        |> custom nip
        |> required "password" string


nip : Decoder NIP
nip =
    decode (,)
        |> required "network_id" string
        |> required "server_ip" string
