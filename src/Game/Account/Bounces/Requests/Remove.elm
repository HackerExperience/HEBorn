module Game.Account.Bounces.Requests.Remove exposing (removeRequest)

import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Utils.Json.Decode exposing (commonError, message)
import Requests.Requests as Requests exposing (report_)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Shared as Bounces exposing (RemoveError(..))


type alias Data =
    Result RemoveError ()


removeRequest : Bounces.ID -> ID -> FlagsSource a -> Cmd Data
removeRequest bounceId id flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.bounceRemove id) (encoder bounceId)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


encoder : Bounces.ID -> Value
encoder bounceId =
    Encode.object
        [ ( "bounce_id", Encode.string bounceId ) ]


errorToString : RemoveError -> String
errorToString error =
    case error of
        RemoveBadRequest ->
            "Bad Request"

        RemoveUnknown ->
            "Unknown"


errorMessage : Decoder RemoveError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed RemoveBadRequest

                value ->
                    fail <| commonError "bounce update error message" value


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report_ "Bounces.Remove" code flagsSrc
                |> Result.mapError (always RemoveUnknown)
                |> Result.andThen Err
