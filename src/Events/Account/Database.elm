module Events.Account.Database
    exposing
        ( Event(..)
        , PasswordAcquiredData
        , handler
        )

import Dict
import Json.Decode
    exposing
        ( Decoder
        , decodeValue
        , map
        , andThen
        , string
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Utils.Events exposing (Handler, notify)
import Game.Network.Types exposing (NIP)
import Game.Account.Database.Models exposing (..)


-- TODO: move changed to sync


type Event
    = PasswordAcquired PasswordAcquiredData


type alias PasswordAcquiredData =
    { nip : NIP
    , password : String
    , processId : String
    , gatewayId : String
    }


handler : String -> Handler Event
handler event json =
    case event of
        "server_password_acquired" ->
            onServerPasswordAcquired json

        _ ->
            Nothing



-- internals


onServerPasswordAcquired : Handler Event
onServerPasswordAcquired json =
    decodeValue passwordAcquired json
        |> notify


passwordAcquired : Decoder Event
passwordAcquired =
    decode PasswordAcquiredData
        |> custom nip
        |> required "password" string
        |> required "process_id" string
        |> required "gateway_id" string
        |> map PasswordAcquired


nip : Decoder ( String, String )
nip =
    decode (,)
        |> required "network_id" string
        |> required "server_ip" string
