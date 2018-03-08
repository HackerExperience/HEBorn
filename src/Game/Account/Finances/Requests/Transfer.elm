module Game.Account.Finances.Requests.Transfer
    exposing
        ( Payload
        , Data
        , transferRequest
        )

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models as Account
import Game.Meta.Types.Network as Network
import Game.Account.Finances.Models as Finances exposing (AccountNumber)


type alias Payload =
    { fromBank : Network.NIP
    , fromAcc : AccountNumber
    , toBank : Network.NIP
    , toAcc : AccountNumber
    , password : String
    , value : Int
    }


type alias Data =
    Result () ()


transferRequest :
    Payload
    -> Account.ID
    -> FlagsSource a
    -> Cmd Data
transferRequest payload accountId flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.bankTransfer accountId) (encoder payload)
        |> Cmd.map (uncurry receiver)



-- internals


encoder : Payload -> Value
encoder { fromBank, fromAcc, toBank, toAcc, password, value } =
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


receiver : Code -> Value -> Data
receiver code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            Err ()



--module Game.Account.Finances.Requests.Transfer
--    exposing
--        ( request
--        , receive
--        )
--import Json.Encode as Encode
--import Requests.Requests as Requests
--import Requests.Topics as Topics
--import Requests.Types exposing (FlagsSource, Code(..), ResponseType)
--import Game.Account.Models as Account
--import Game.Meta.Types.Network as Network
--import Game.Account.Finances.Models exposing (..)
--import Game.Account.Finances.Messages
--    exposing
--        ( Msg(..)
--        , RequestMsg(..)
--        , TransferResponse(..)
--        )
--import Game.Meta.Types.Apps.Desktop exposing (Requester)
--type TransferResponse
--    = Successful
--    | Error
--request :
--    BankTransferRequest
--    -> Requester
--    -> Account.ID
--    -> FlagsSource a
--    -> Cmd Msg
--request { fromBank, fromAcc, toBank, toAcc, password, value } requester accountId data =
--    let
--        payload =
--            Encode.object
--                [ ( "from_bank_net", Encode.string (Network.getId fromBank) )
--                , ( "from_bank_ip", Encode.string (Network.getIp fromBank) )
--                , ( "from_acc", Encode.int fromAcc )
--                , ( "to_bank_net", Encode.string (Network.getId toBank) )
--                , ( "to_bank_ip", Encode.string (Network.getIp toBank) )
--                , ( "to_acc", Encode.int toAcc )
--                , ( "password", Encode.string password )
--                , ( "value", Encode.int value )
--                ]
--    in
--        Requests.request (Topics.bankTransfer accountId)
--            (BankTransfer requester >> Request)
--            payload
--            data
--receive : ResponseType -> TransferResponse
--receive ( code, json ) =
--    case code of
--        OkCode ->
--            Successful
--        _ ->
--            -- TODO: Threat this error properly
--            Error
