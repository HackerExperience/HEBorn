module Game.Bank.Requests.Logout exposing (logoutRequest, Data)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Finances.Models exposing (AccountId)
import Game.Bank.Shared exposing (..)


type alias Data =
    Result LogoutError ()


logoutRequest :
    AccountId
    -> String
    -> FlagsSource a
    -> Cmd Data
logoutRequest id requestId flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bankLogout id requestId) emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


errorToString : LogoutError -> String
errorToString error =
    case error of
        LOBadRequest ->
            "Bad Request"


errorMessage : Decoder LogoutError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed LOBadRequest

                value ->
                    commonError "bank account logout error message" value
                        |> fail


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Bank.Logout" code flagsSrc
                |> Result.mapError (always LOBadRequest)
                |> Result.andThen Err
