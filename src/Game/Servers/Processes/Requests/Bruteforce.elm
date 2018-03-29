module Game.Servers.Processes.Requests.Bruteforce
    exposing
        ( Data
        , Errors(..)
        , bruteforceRequest
        , errorToString
        )

import Json.Decode exposing (Value, Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode
import Utils.Json.Decode exposing (commonError, message)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Meta.Types.Network as Network
import Game.Servers.Shared exposing (CId)


-- not a bool because we'll threat errors


type alias Data =
    Result Errors ()


type Errors
    = BadRequest
    | Unknown


bruteforceRequest :
    Network.ID
    -> Network.IP
    -> CId
    -> FlagsSource a
    -> Cmd Data
bruteforceRequest network targetIp cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bruteforce cid)
            (encoder network targetIp)
        |> Cmd.map (uncurry <| receiver flagsSrc)


errorToString : Errors -> String
errorToString error =
    case error of
        BadRequest ->
            "Shit happened!"

        Unknown ->
            "Shit happened!1!!1!"



-- internals


encoder : Network.ID -> Network.IP -> Value
encoder network targetIp =
    Encode.object
        [ ( "network_id", Encode.string <| network )
        , ( "ip", Encode.string <| targetIp )
        , ( "bounces", Encode.list [] )
        ]


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Processes.Bruteforce" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


errorMessage : Decoder Errors
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed BadRequest

                value ->
                    fail <| commonError "download error message" value
