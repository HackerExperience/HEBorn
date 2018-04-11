module Game.Account.Requests.ActionPerformed exposing (Data, request)

import Json.Decode as Decode
    exposing
        ( Decoder
        , decodeValue
        , succeed
        , fail
        )
import Json.Encode as Encode exposing (Value)
import Utils.Json.Decode exposing (message, commonError)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Account.Models exposing (ID)
import Game.Meta.Types.ClientActions as ClientActions exposing (ClientActions(..))


type alias Data =
    Result Error ()


type Error
    = Unknown
    | BadAction


request : ClientActions -> ID -> FlagsSource a -> Cmd Data
request action accId flagsSrc =
    flagsSrc
        |> Requests.request
            (Topics.clientActionPerformed accId)
            (encoder action)
        |> Cmd.map (uncurry <| receiver flagsSrc)



-- internals


receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code json =
    case code of
        OkCode ->
            Ok ()

        ErrorCode ->
            json
                |> decodeValue errorMessage
                |> report "Client.Action.Performed" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err

        _ ->
            Err Unknown


encoder : ClientActions -> Value
encoder performedAction =
    Encode.object
        [ ( "action", Encode.string <| ClientActions.toString performedAction ) ]


errorMessage : Decoder Error
errorMessage =
    message <|
        \str ->
            case str of
                "bad_action" ->
                    succeed BadAction

                value ->
                    fail <| commonError "action performed error message" value
