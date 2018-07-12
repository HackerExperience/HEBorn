module Game.Bank.Requests.Transfer exposing (transferRequest, Data)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Models exposing (..)
import Game.Account.Database.Models exposing (Token)
import Game.Account.Finances.Models exposing (AccountId, AtmId, AccountNumber)
import Game.Bank.Shared exposing (..)
import Game.Meta.Types.Network exposing (IP)
import Game.Servers.Shared exposing (..)


type alias Data =
    Result TransferError ()


transferRequest :
    AccountId
    -> String
    -> AccountNumber
    -> IP
    -> Int
    -> FlagsSource a
    -> Cmd Data
transferRequest id requestId acc ip amount flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bankTransfer id requestId)
            (encoder acc ip amount)
        |> Cmd.map (uncurry <| receiver flagsSrc)


encoder : AccountNumber -> IP -> Int -> Value
encoder account ip amount =
    Encode.object
        [ ( "to_acc", Encode.int account )
        , ( "to_bank_net", Encode.string "::" )
        , ( "to_bank_ip", Encode.string ip )
        , ( "amount", Encode.int amount )
        ]



-- internals


errorToString : TransferError -> String
errorToString error =
    case error of
        TFBadRequest ->
            "Bad Request"

        TFNotABank ->
            "You can't transfer because the given ip is not a bank."

        TFNotEnoughFunds ->
            "You can't transfer because you don't have enough funds"

        TFAccountNotExists ->
            "You can`t transfer because the destiny account do not exist."


errorMessage : Decoder TransferError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed TFBadRequest

                "nip_not_found" ->
                    succeed TFNotABank

                "atm_not_a_bank" ->
                    succeed TFNotABank

                "bank_account_not_found" ->
                    succeed TFAccountNotExists

                "bank_account_no_funds" ->
                    succeed TFNotEnoughFunds

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
                |> Result.mapError (always TFBadRequest)
                |> Result.andThen Err
