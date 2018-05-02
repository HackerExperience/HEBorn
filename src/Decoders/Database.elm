module Decoders.Database exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , andThen
        , map
        , list
        , bool
        , string
        , float
        , int
        , fail
        , succeed
        )
import Json.Decode.Pipeline
    exposing
        ( decode
        , required
        , custom
        , optional
        , hardcoded
        )
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Meta.Types.Network exposing (NIP)
import Game.Shared exposing (ID)
import Game.Account.Database.Models exposing (..)
import Game.Account.Finances.Models exposing (AccountNumber)


database : Decoder Model
database =
    decode Model
        |> required "servers" servers
        |> required "bank_accounts" hackedBankAccounts
        --required "btc_wallets"
        |> hardcoded Dict.empty


virus : Decoder Virus
virus =
    decode Virus
        |> required "name" string
        |> required "version" float
        |> required "type" (string |> andThen virusType)
        |> required "extension" string
        |> optionalMaybe "running_time" float
        |> required "is_active" bool


viruses : Decoder Viruses
viruses =
    map Dict.fromList <| list virusWithIndex


virusType : String -> Decoder VirusType
virusType str =
    case str of
        "virus_spyware" ->
            succeed Spyware

        "adware" ->
            succeed Adware

        "btc_miner" ->
            succeed BTCMiner

        error ->
            fail <| commonError "virus_type" error


virusWithIndex : Decoder ( ID, Virus )
virusWithIndex =
    decode (,)
        |> required "file_id" string
        |> custom virus


servers : Decoder HackedServers
servers =
    decode (,)
        |> custom nip
        |> custom hackedServer
        |> list
        |> map Dict.fromList


hackedServer : Decoder HackedServer
hackedServer =
    decode HackedServer
        |> required "password" string
        |> optionalMaybe "alias" string
        |> optionalMaybe "notes" string
        |> required "viruses" viruses


nip : Decoder NIP
nip =
    decode (,)
        |> required "network_id" string
        |> required "ip" string


bankAccountEntry : Decoder ( HackedBankAccountID, HackedBankAccount )
bankAccountEntry =
    decode (,)
        |> custom hackedBankAccountId
        |> custom hackedBankAccount


hackedBankAccounts : Decoder HackedBankAccounts
hackedBankAccounts =
    map Dict.fromList <| list bankAccountEntry


hackedBankAccountId : Decoder HackedBankAccountID
hackedBankAccountId =
    decode (,)
        |> required "atm_id" string
        |> required "account_num" int


hackedBankAccount : Decoder HackedBankAccount
hackedBankAccount =
    decode HackedBankAccount
        |> hardcoded "Bank bem louco"
        |> optionalMaybe "password" string
        |> optionalMaybe "known_balance" int
        |> optionalMaybe "token" string
        |> optionalMaybe "notes" string
        |> optionalMaybe "last_login_date" float
        |> required "last_update" float


virusCollected : Decoder ( AtmId, AccountNumber, Int, ID, NIP )
virusCollected =
    decode (,,,,)
        |> required "atm_id" string
        |> required "account_number" int
        |> required "money" int
        |> required "file_id" string
        |> required "nip" nip
