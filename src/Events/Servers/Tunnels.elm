module Events.Servers.Tunnels
    exposing
        ( Event(..)
        , Index
        , Tunnel
        , Connections
        , Connection
        , handler
        , decoder
        )

import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , list
        , maybe
        , string
        )
import Json.Decode.Pipeline exposing (optional, required, decode)
import Utils.Events exposing (Handler, notify)


type Event
    = Changed Index


type alias Index =
    List Tunnel


type alias Tunnel =
    { bounce : Maybe String
    , nip : String
    , connections : Connections
    }


type alias Connections =
    List Connection


type alias Connection =
    { id : String
    , type_ : String
    }


handler : String -> Handler Event
handler event json =
    case event of
        "changed" ->
            onChanged json

        _ ->
            Nothing


decoder : Decoder Index
decoder =
    list tunnel



-- internals


onChanged : Handler Event
onChanged json =
    decodeValue decoder json
        |> Result.map Changed
        |> notify


tunnel : Decoder Tunnel
tunnel =
    decode Tunnel
        |> optional "bounce" (maybe string) Nothing
        |> required "nip" string
        |> required "connections" (list connection)


connection : Decoder Connection
connection =
    decode Connection
        |> required "id" string
        |> required "type" string
