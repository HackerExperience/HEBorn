module Game.Servers.Requests.Fetch
    exposing
        ( Response(..)
        , Server
        , receive
        , decoder
        )

import Json.Decode.Pipeline exposing (decode, required, custom)
import Json.Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , list
        , index
        , string
        , float
        , value
        )
import Requests.Requests as Requests
import Requests.Types exposing (ConfigSource, Code(..), emptyPayload)


type Response
    = Okay Server


type alias Server =
    { id : String
    , name : String
    , coordinates : Float
    , nip : ( String, String )
    , logs : Value
    , filesystem : Value

    -- remaining fields:
    --, nips : List (String, String)
    --, processes : Value
    --, tunnels : Value
    --, meta : Value
    }


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            decodeValue decoder json
                |> Result.map Okay
                |> Result.toMaybe

        _ ->
            Nothing


decoder : Decoder Server
decoder =
    decode Server
        |> required "id" string
        |> required "name" string
        |> required "coordinates" float
        |> required "nip" decodeNip
        |> required "logs" value
        |> required "filesystem" value



-- internals


decodeNip : Decoder ( String, String )
decodeNip =
    decode (\network ip -> ( network, ip ))
        |> custom (index 0 string)
        |> custom (index 1 string)
