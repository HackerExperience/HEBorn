module Game.Account.Finances.Requests.Transfer
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Decoders.Processes
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Network as Network
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Messages exposing (Msg(..))
import Apps.Reference exposing (Reference)


type Response
    = Successful
    | Error


request :
    NIP
    -> AccountNumber
    -> NIP
    -> AccountNumber
    -> String
    -> Int
    -> Reference
    -> ConfigSource a
    -> Cmd msg
request fromBank fromAcc toBank toAcc password value requester data =
    let
        payload =
            Encode.object
                [ ( "from_bank_net", Encode.string (Network.getId fromBank) )
                , ( "from_bank_ip", Encode.string (Network.getIp fromBank) )
                , ( "from_acc", Encode.int fromAcc )
                , ( "to_bank_net", Encode.string (Network.getId toBank) )
                , ( "to_bank_ip", Encode.string (Network.getIp toBank) )
                , ( "to_acc", Encode.int toAcc )
                , ( "password", Encode.string password )
                , ( "value", Encode.int value )
                ]

        accountId =
            data
                |> Game.getAccount
                |> Account.getId
    in
        Requests.request (Topics.bankTransfer accountId)
            (BankTransfer requester >> Request)
            payload
            data


receive : Code -> Naybe Response
receive code =
    case code of
        OkCode ->
            Just Successful

        _ ->
            -- TODO: Threat this error properly
            Just Error
