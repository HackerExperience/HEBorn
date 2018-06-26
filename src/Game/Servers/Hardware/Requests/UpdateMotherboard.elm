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
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Decoders.Hardware
import Game.Servers.Shared exposing (CId)
import Game.Meta.Types.Components.Motherboard as Motherboard exposing (Motherboard)


{-| Resultados possíveis para o request, ele pode dar erro ou retornar a
motherboard atualizada.
-}
type alias Data =
    Result Errors Motherboard


{-| Tipos de erros que podem rolar ao efetuar o request, seria uma boa ideia
tirar as piadas:

  - PorraKress

Deu um erro e a culpa é do client side.

  - NaughtySlot

Problema nos dados do slot.

  - UnhealthyFriends

Problema na network connection.

  - CoitusInterruptus

Motherboard não contém componentes iniciais.

  - TryinToUseGod

Tentando conectar um componente que não existe.

  - WrongHole

Tentando conectar um componente no slot errado.

  - RobinHood

Tentando usar um componente ou network que não pertence ao jogador.

  - ConnectionRequired

Motherboard não tem um IP público.

  - WrongToolForTheJob

Tentando usar um componente que não é uma motherboard como uma motherboard.

  - Unknown

Erro desconhecido pelo client.

-}
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


{-| Cria um Cmd de request para atualizar a motherboard.
-}
updateMotherboardRequest : Motherboard -> CId -> FlagsSource a -> Cmd Data
updateMotherboardRequest motherboard cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.updateMotherboard cid)
            (Motherboard.encode motherboard)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- funções internas


{-| Converte dados raw da resposta do request em um formato validado.
-}
receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            value
                |> decodeValue Decoders.Hardware.motherboard
                |> report "Hardware.UpdateMotherboard" code flagsSrc
                |> Result.mapError (always Unknown)

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Hardware.UpdateMotherboard" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


{-| Decoder para mensagem de erro.
-}
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
