module Game.Servers.Settings.Check exposing (Response(..), request, receive)

import Requests.Requests as Requests
import Requests.Topics as Topics
import Json.Decode as Decode exposing (Value)
import Game.Servers.Settings.Types exposing (..)
import Game.Servers.Shared exposing (..)
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)


type Response
    = Valid Value
    | Invalid String


request : (ResponseType -> msg) -> Configs -> CId -> ConfigSource a -> Cmd msg
request msg config cid =
    Requests.request (Topics.serverConfigCheck cid) msg (encode config)


receive : Code -> Decode.Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            Just <| Valid json

        _ ->
            case Decode.decodeValue decodeError json of
                Ok msg ->
                    Just <| Invalid msg

                Err msg ->
                    let
                        _ =
                            Debug.log
                                "▶ Invalid server config.check response:"
                                msg
                    in
                        Nothing
