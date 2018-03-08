module Setup.Requests.SetServer exposing (Data, setServerRequest)

import Json.Decode as Decode exposing (Value)
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ResponseType, FlagsSource, Code(..))
import Game.Servers.Shared as Servers
import Setup.Settings exposing (..)


type alias Data =
    List Settings


setServerRequest : List Settings -> Servers.CId -> FlagsSource a -> Cmd Data
setServerRequest settings cid flagsSrc =
    let
        payload =
            settings
                |> List.map encodeSettings
                |> Encode.object
    in
        flagsSrc
            |> Requests.request (Topics.serverConfigSet cid) payload
            |> Cmd.map (uncurry <| receiver settings)



-- internals


receiver : List Settings -> Code -> Value -> Data
receiver settings code value =
    case code of
        OkCode ->
            []

        _ ->
            case Decode.decodeValue (decodeErrors settings) value of
                Ok settings ->
                    settings

                Err _ ->
                    settings
