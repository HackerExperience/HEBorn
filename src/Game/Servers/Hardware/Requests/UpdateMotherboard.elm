module Game.Servers.Hardware.Requests.UpdateMotherboard
    exposing
        ( Response(..)
        , request
        , receive
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        )
import Utils.Json.Decode exposing (commonError)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)
import Game.Servers.Hardware.Messages exposing (..)
import Decoders.Hardware


type Response
    = Okay Motherboard
    | PorraKress
    | NaughtySlot
    | UnhealthyFriends
    | CoitusInterruptus
    | TryinToUseGod
    | WrongHole
    | RobinHood
    | ConnectionRequired
    | WrongToolForTheJob
    | Error


request : Motherboard -> CId -> FlagsSource a -> Cmd Msg
request motherboard cid =
    Requests.request (Topics.updateMotherboard cid)
        (UpdateMotherboardRequest >> Request)
    <|
        Motherboard.encode motherboard


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue Decoders.Hardware.motherboard
                |> Requests.report
                |> Maybe.map Okay

        ErrorCode ->
            Requests.decodeGenericError
                json
                decodeErrorMessage

        _ ->
            Just Error


decodeErrorMessage : String -> Decoder Response
decodeErrorMessage str =
    case str of
        "bad_src" ->
            succeed PorraKress

        "bad_slot_data" ->
            succeed NaughtySlot

        "bad_network_connections" ->
            succeed UnhealthyFriends

        "motherboard_missing_initial_components" ->
            succeed CoitusInterruptus

        "component_not_found" ->
            succeed TryinToUseGod

        "motherboard_wrong_slot_type" ->
            succeed WrongHole

        "motherboard_bad_slot" ->
            succeed NaughtySlot

        "component_not_belongs" ->
            succeed RobinHood

        "network_connection_not_belongs" ->
            succeed RobinHood

        "motherboard_missing_public_nip" ->
            succeed ConnectionRequired

        "component_not_motherboard" ->
            succeed WrongToolForTheJob

        value ->
            fail <| commonError "mobo update error message" value
