module Game.Bank.Requests.CloseAccount exposing (closeAccountRequest, Data)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Models exposing (..)
import Game.Account.Finances.Models exposing (AccountId)
import Game.Bank.Shared exposing (..)
import Game.Account.Database.Models as Database
import Game.Meta.Types.Network as Network


type alias Data =
    Result CloseAccountError ()


closeAccountRequest :
    AccountId
    -> String
    -> FlagsSource a
    -> Cmd Data
closeAccountRequest id requestId flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bankCloseAcc id requestId) emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


errorToString : CloseAccountError -> String
errorToString error =
    case error of
        ClAccBadRequest ->
            "Bad Request"

        ClAccBankAccountNotBelongs ->
            "You don't own this account."

        ClAccBankAccountNotEmpty ->
            "You can't close this account because it's not empty."


errorMessage : Decoder CloseAccountError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed ClAccBadRequest

                "bank_account_not_belongs" ->
                    succeed ClAccBankAccountNotBelongs

                "bank_account_not_empty" ->
                    succeed ClAccBankAccountNotEmpty

                value ->
                    commonError "bank account close error message" value
                        |> fail


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Bank.CloseAcc" code flagsSrc
                |> Result.mapError (always ClAccBadRequest)
                |> Result.andThen Err
