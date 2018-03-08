module Game.Account.Database.Requests.CollectWithBank
    exposing
        ( collectWithBankRequest
        )

import Utils.Json.Decode exposing (commonError, message)
import Json.Decode as Decode exposing (Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode exposing (Value)
import Requests.Types exposing (FlagsSource, Code(..))
import Requests.Topics as Topics
import Requests.Requests as Requests exposing (report)
import Game.Account.Models exposing (..)
import Game.Account.Bounces.Models as Bounces
import Game.Account.Bounces.Shared as Bounces
import Game.Account.Database.Models as Database
import Game.Account.Database.Shared exposing (..)
import Game.Account.Finances.Models as Finances
import Game.Servers.Shared as Servers exposing (CId(..))
import Game.Meta.Types.Network as Network


type alias Data =
    Result CollectWithBankError ()


collectWithBankRequest :
    ID
    -> List ID
    -> Maybe Bounces.ID
    -> Finances.AccountId
    -> ID
    -> FlagsSource a
    -> Cmd Data
collectWithBankRequest gateway viruses bounce ( atmId, accNumber ) id flagsSrc =
    flagsSrc
        |> Requests.request (Topics.virusCollect id)
            (encoder gateway viruses bounce atmId accNumber)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


encoder :
    ID
    -> List ID
    -> Maybe Bounces.ID
    -> Finances.AtmId
    -> Finances.AccountNumber
    -> Value
encoder gateway viruses bounceId atmId accNum =
    let
        valueList =
            List.map (Encode.string) viruses

        base =
            [ ( "gateway_id", Encode.string gateway )
            , ( "viruses", Encode.list valueList )
            , ( "atm_id", Encode.string atmId )
            , ( "account_number", Encode.int accNum )
            ]

        obj =
            case bounceId of
                Just bounceId ->
                    ( "bounce_id", Encode.string bounceId ) :: base

                Nothing ->
                    base
    in
        Encode.object obj


errorMessage : Decoder CollectWithBankError
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed CollectUSDBadRequest

                value ->
                    fail <| commonError "virus collect error message" value


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Virus.Collect" code flagsSrc
                |> Result.mapError (always UnkownCollectError)
                |> Result.andThen Err
