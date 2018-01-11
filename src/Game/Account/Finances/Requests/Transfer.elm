module Game.Account.Finances.Requests.Transfer
    exposing
        ( request
        , receive
        )

import Json.Encode as Encode
import Json.Decode exposing (Value, decodeValue)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Game.Servers.Shared exposing (CId)
import Requests.Types exposing (ConfigSource, Code(..), ResponseType)
import Decoders.Processes
import Game.Models as Game
import Game.Account.Models as Account
import Game.Meta.Types.Network as Network
import Game.Account.Finances.Models exposing (..)
import Game.Account.Finances.Messages
    exposing
        ( Msg(..)
        , RequestMsg(..)
        , TransferResponse(..)
        )
import Game.Web.Models as Web


request :
    Network.NIP
    -> AccountNumber
    -> Network.NIP
    -> AccountNumber
    -> String
    -> Int
    -> Web.Requester
    -> Account.ID
    -> CId
    -> ConfigSource a
    -> Cmd Msg
request fromBank fromAcc toBank toAcc password value requester accountId cid data =
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
    in
        Requests.request (Topics.bankTransfer accountId)
            (BankTransfer requester cid >> Request)
            payload
            data


receive : ResponseType -> TransferResponse
receive ( code, json ) =
    case code of
        OkCode ->
            Successful

        _ ->
            -- TODO: Threat this error properly
            Error
