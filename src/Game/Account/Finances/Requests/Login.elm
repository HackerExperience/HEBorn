module Game.Account.Finances.Requests.Login
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Core.Error as Error
import Decoders.Bank exposing (accountData, loginError)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Decoders.Processes
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Network as Network
import Apps.Browser.Pages.Bank.Models exposing (AccountData)
import Apps.Reference exposing (Reference)


type Response
    = Valid AccountData
    | Invalid


request :
    Game.Data
    -> NIP
    -> AccountNumber
    -> String
    -> Reference
    -> ConfigSource a
    -> Cmd msg
request data bank accountNum password requester data =
    let
        payload =
            Encode.object
                [ ( "bank_net", Encode.string (Network.getId bank) )
                , ( "bank_ip", Encode.string (Network.getIp bank) )
                , ( "account", Encode.int account )
                , ( "password", Encode.string password )
                ]

        accountId =
            data
                |> Game.getAccount
                |> Account.getId
    in
        Requests.request (Topics.bankLogin accountId)
            (BankLogin requester >> Request)
            payload
            data


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            case (decodeValue accountData json) of
                Ok accountData ->
                    Just <| Valid accountData

                Err msg ->
                    Error.porra msg
                        |> Core.Crash
                        |> Dispatch.core

        _ ->
            Just <| Invalid
