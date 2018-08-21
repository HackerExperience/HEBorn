module Game.Bank.Requests.Resync exposing (Data, resyncRequest)

import Time exposing (Time)
import Json.Decode as Decode exposing (Value, decodeValue)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), emptyPayload)
import Decoders.Bank as Decoder
import Game.Account.Finances.Models exposing (AccountId)
import Game.Bank.Shared exposing (BankAccountData)
import Game.Servers.Shared exposing (..)


type alias Data =
    Result () ( AccountId, BankAccountData )


resyncRequest : AccountId -> String -> FlagsSource a -> Cmd Data
resyncRequest id requestId flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bankResync id requestId)
            emptyPayload
        |> Cmd.map (uncurry <| receiver flagsSrc id)



-- internals


receiver :
    FlagsSource a
    -> AccountId
    -> Code
    -> Value
    -> Data
receiver flagsSrc accountId code value =
    case code of
        OkCode ->
            value
                |> decodeValue Decoder.accountData
                |> report "Bank.Resync" code flagsSrc
                |> Result.map ((,) accountId)
                |> Result.mapError (always ())

        _ ->
            Err ()
