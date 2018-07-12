module Game.Bank.Requests.CreateAccount exposing (createAccountRequest, Data)

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Models exposing (..)
import Game.Account.Finances.Models exposing (AtmId)
import Game.Bank.Shared exposing (..)
import Game.Servers.Shared exposing (..)


type alias Data =
    Result CreateAccountError ()


createAccountRequest :
    ID
    -> AtmId
    -> CId
    -> FlagsSource a
    -> Cmd Data
createAccountRequest id atmId cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.accountBankCreateAcc id)
            (encoder atmId cid)
        |> Cmd.map (uncurry <| receiver flagsSrc)


encoder : AtmId -> CId -> Value
encoder atmId cid =
    case cid of
        GatewayCId serverId ->
            Encode.object
                [ ( "atm_id", Encode.string atmId )
                , ( "gateway", Encode.string serverId )
                ]

        _ ->
            emptyPayload



-- internals


errorToString : CreateAccountError -> String
errorToString error =
    case error of
        CrAccBadRequest ->
            "Bad Request"

        CrAccServerNotBelongs ->
            "You can't create this account because the server is not yours."


errorMessage : Decoder CreateAccountError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed CrAccBadRequest

                "server_not_belongs" ->
                    succeed CrAccServerNotBelongs

                value ->
                    commonError "bank account create error message" value
                        |> fail


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Bank.CreateAcc" code flagsSrc
                |> Result.mapError (always CrAccBadRequest)
                |> Result.andThen Err
