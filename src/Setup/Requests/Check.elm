module Setup.Requests.Check exposing (..)

import Native.Panic
import Core.Error as Error
import Json.Decode as Decode exposing (Decoder, Value, decodeValue)
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)
import Game.Servers.Shared exposing (CId)
import Utils.Ports.Map exposing (Coordinates)
import Setup.Settings exposing (..)


{- This is a meta/multi request module, use it to build custom requests -}


serverName : (Bool -> msg) -> String -> CId -> ConfigSource a -> Cmd msg
serverName func name cid =
    [ encodeSettings <| Name name ]
        |> Encode.object
        |> Requests.request (Topics.serverConfigCheck cid)
            (uncurry receiveServerName >> func)


serverLocation :
    (Maybe String -> msg)
    -> Coordinates
    -> CId
    -> ConfigSource a
    -> Cmd msg
serverLocation func coords cid =
    [ encodeSettings <| Location coords ]
        |> Encode.object
        |> Requests.request (Topics.serverConfigCheck cid)
            (uncurry receiveServerLocation >> func)



-- internals


receiveServerName : Code -> Value -> Bool
receiveServerName code value =
    case code of
        OkCode ->
            True

        _ ->
            -- note that we're catching every error code, we should define
            -- the correct error code for expected errors and crash with
            -- the others
            False


receiveServerLocation : Code -> Value -> Maybe String
receiveServerLocation code value =
    case code of
        OkCode ->
            case decodeValue decodeLocation value of
                Ok string ->
                    Just string

                Err msg ->
                    -- TODO: define errors
                    Nothing

        _ ->
            Nothing


decodeLocation : Decoder String
decodeLocation =
    Decode.field "address" Decode.string
