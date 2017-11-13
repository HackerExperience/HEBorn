module Game.Servers.Settings.Check exposing (..)

import Native.Panic
import Core.Error as Error
import Requests.Requests as Requests
import Requests.Topics as Topics
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Game.Servers.Settings.Types exposing (..)
import Game.Servers.Shared exposing (..)
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)


request :
    (ResponseType -> msg)
    -> Settings
    -> CId
    -> ConfigSource a
    -> Cmd msg
request msg settings cid =
    Requests.request (Topics.serverConfigCheck cid) msg (encode settings)


receiveName : (Bool -> a) -> Code -> Value -> a
receiveName func code value =
    case code of
        OkCode ->
            func True

        _ ->
            func False


receiveLocation : (Maybe String -> a) -> Code -> Value -> a
receiveLocation func code value =
    case code of
        OkCode ->
            case decodeValue decodeLocation value of
                Ok string ->
                    func <| Just string

                Err msg ->
                    Native.Panic.crash <| Error.request "Settings.Check" msg

        code ->
            func <| Nothing


decodeLocation : Decoder String
decodeLocation =
    Decode.field "address" Decode.string
