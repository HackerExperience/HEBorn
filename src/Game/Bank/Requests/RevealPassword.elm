module Game.Bank.Requests.RevealPassword exposing (revealPasswordRequest, Data)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Database.Models exposing (Token)
import Game.Account.Finances.Models exposing (AtmId)
import Game.Bank.Shared exposing (..)
import Game.Servers.Shared exposing (..)


type alias Data =
    Result RevealPasswordError ()


revealPasswordRequest :
    CId
    -> Token
    -> FlagsSource a
    -> Cmd Data
revealPasswordRequest cid token flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bankRevealPass cid)
            (encoder token)
        |> Cmd.map (uncurry <| receiver flagsSrc)


encoder : Token -> Value
encoder token =
    Encode.object [ ( "token", Encode.string token ) ]



-- internals


errorToString : RevealPasswordError -> String
errorToString error =
    case error of
        RPBadRequest ->
            "Bad Request"

        RPTokenInvalid ->
            "You can't use this token because it is invalid."

        RPTokenExpired ->
            "You can`t use this token because it is expired."


errorMessage : Decoder RevealPasswordError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed RPBadRequest

                "token_expired" ->
                    succeed RPTokenExpired

                "token_invalid" ->
                    succeed RPTokenInvalid

                value ->
                    commonError "reveal bank account password error message" value
                        |> fail


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Bank.RevealPass" code flagsSrc
                |> Result.mapError (always RPBadRequest)
                |> Result.andThen Err
