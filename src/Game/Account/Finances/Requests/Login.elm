module Game.Account.Finances.Requests.Login
    exposing
        ( request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Core.Error as Error
import Core.Dispatch.Core as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Decoders.Bank exposing (accountData)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Game.Servers.Shared exposing (CId)
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)
import Decoders.Processes
import Game.Models as Game
import Game.Account.Models as Account
import Game.Account.Finances.Models as Finances exposing (BankLoginRequest)
import Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , LoginResponse(..)
        )
import Game.Meta.Types.Network as Network
import Game.Meta.Types.Requester exposing (Requester)


request :
    BankLoginRequest
    -> Requester
    -> Account.ID
    -> CId
    -> ConfigSource a
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
