module Game.Servers.Hardware.Requests.UpdateMotherboard
    exposing
        ( Data
        , Errors(..)
        , updateMotherboardRequest
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        )
import Utils.Json.Decode exposing (commonError, message)
import Requests.Requests as Requests exposing (report_)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Decoders.Hardware
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


type alias Data =
    Result Errors Motherboard


type Errors
    = PorraKress
    | NaughtySlot
    | UnhealthyFriends
    | CoitusInterruptus
    | TryinToUseGod
    | WrongHole
    | RobinHood
    | ConnectionRequired
    | WrongToolForTheJob
    | Unknown


updateMotherboardRequest : Motherboard -> CId -> FlagsSource a -> Cmd Data
updateMotherboardRequest motherboard cid flagsSrc =
    flagsSrc
        |> Requests.request_ (Topics.updateMotherboard cid)
            (Motherboard.encode motherboard)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            value
                |> decodeValue Decoders.Hardware.motherboard
                |> report_ "Hardware.UpdateMotherboard" code flagsSrc
                |> Result.mapError (always Unknown)

        _ ->
            value
                |> decodeValue errorMessage
                |> report_ "Hardware.UpdateMotherboard" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


errorMessage : Decoder Errors
errorMessage =
    message <|
        \str ->
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
