module Game.Account.Finances.Requests.Login
    exposing
        ( request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Decoders.Bank exposing (accountData)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Game.Servers.Shared exposing (CId)
import Requests.Types exposing (FlagsSource, Code(..), ResponseType)
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances exposing (BankLoginRequest)
import Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , LoginResponse(..)
        )
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Apps.Desktop exposing (Requester)


request :
    BankLoginRequest
    -> Requester
    -> Account.ID
    -> CId
    -> FlagsSource a
    -> Cmd Msg
request { bank, accountNum, password } requester accountId cid data =
    let
        payload =
            Encode.object
                [ ( "bank_net", Encode.string (Network.getId bank) )
                , ( "bank_ip", Encode.string (Network.getIp bank) )
                , ( "account", Encode.int accountNum )
                , ( "password", Encode.string password )
                ]
    in
        Requests.request (Topics.bankLogin accountId)
            (BankLogin requester cid >> Request)
            payload
            data


receive : ResponseType -> LoginResponse
receive ( code, json ) =
    case code of
        OkCode ->
            case (decodeValue accountData json) of
                Ok accountData ->
                    Valid accountData

                Err msg ->
                    DecodeFailed

        _ ->
            --TODO: Threat this error properly
            Invalid
