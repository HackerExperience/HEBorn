module Decoders.Database exposing (..)

import Dict
import Json.Decode as Decode
    exposing
        ( Decoder
        , andThen
        , map
        , list
        , string
        , float
        , int
        , fail
        , succeed
        )
import Json.Decode.Pipeline exposing (decode, required, custom)
import Utils.Json.Decode exposing (optionalMaybe, commonError)
import Game.Meta.Types.Network exposing (NIP)
import Game.Account.Database.Models exposing (..)


activeVirus : Decoder RunningVirus
activeVirus =
    decode (,)
        |> required "id" string
        |> required "since" float


virus : Decoder InstalledVirus
virus =
    decode (,,)
        |> required "id" string
        |> required "filename" string
        |> required "version" float


serverType : String -> Decoder ServerType
serverType str =
    case str of
        "corp" ->
            succeed Corporation

        "npc" ->
            succeed NPC

        "player" ->
            succeed Player

        error ->
            fail <| commonError "server_type" error


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
        --|> custom nip
        |> required "password" string
        |> optionalMaybe "label" string
        |> optionalMaybe "notes" string
        |> required "viruses" (list virus)
        |> optionalMaybe "active" activeVirus
        |> required "type" (string |> andThen serverType)
        |> optionalMaybe "remote" string


nip : Decoder NIP
nip =
    decode (,)
        |> required "netid" string
        |> required "ip" string


bankAccountEntry : Decoder ( HackedBankAccountID, HackedBankAccount )
bankAccountEntry =
    decode (,)
        |> custom hackedBankAccountId
        |> custom hackedBankAccount


hackedBankAccountId : Decoder HackedBankAccountID
hackedBankAccountId =
    decode (,)
        |> required "atm_id" string
        |> required "account_num" int


hackedBankAccount : Decoder HackedBankAccount
hackedBankAccount =
    decode HackedBankAccount
        |> required "name" string
        |> required "password" string
        |> required "balance" int
