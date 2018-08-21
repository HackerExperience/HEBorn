module Game.Bank.Requests.ChangePassword exposing (changePasswordRequest, Data)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Finances.Models exposing (AccountId)
import Game.Bank.Shared exposing (..)

type alias Data =
    Result ChangePassError ()


changePasswordRequest :
    AccountId
    -> String
    -> FlagsSource a
    -> Cmd Data
changePasswordRequest id requestId flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bankChangePass id requestId) emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc)


-- internals


errorToString : ChangePassError -> String
errorToString error =
    case error of
        CPBadRequest ->
            "Bad Request"

        CPBankAccountNotBelongs ->
            "You don't own this account."


errorMessage : Decoder ChangePassError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed CPBadRequest

                "bank_account_not_belongs" ->
                    succeed CPBankAccountNotBelongs

                value ->
                    commonError "bank account change password error message" value
                        |> fail


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Bank.ChangePass" code flagsSrc
                |> Result.mapError (always CPBadRequest)
                |> Result.andThen Err
