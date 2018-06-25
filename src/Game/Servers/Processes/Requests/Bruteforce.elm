module Game.Servers.Processes.Requests.Bruteforce
    exposing
        ( Data
        , Errors(..)
        , bruteforceRequest
        , errorToString
        )

{-| Contém request bruteforce.
-}

import Json.Decode exposing (Value, Decoder, decodeValue, succeed, fail)
import Json.Encode as Encode
import Utils.Json.Decode exposing (commonError, message)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Meta.Types.Network as Network
import Game.Servers.Shared exposing (CId)


{-| Resultado do request, não é um Maybe pois o tratamento de sucesso pode
ser interessante um dia e a falta de typeclasses do elm nos forçaria a
reescrever tudo se deixarmos pra mudar o tipo depois.
-}
type alias Data =
    Result Errors ()


{-| Tipos de erros que podem ocorrer ao realizar o request.
-}
type Errors
    = BadRequest
    | Unknown


{-| Cria um Cmd de request para atualizar a motherboard.
-}
bruteforceRequest :
    Network.ID
    -> Network.IP
    -> CId
    -> FlagsSource a
    -> Cmd Data
bruteforceRequest network targetIp cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.bruteforce cid)
            (encoder network targetIp)
        |> Cmd.map (uncurry <| receiver flagsSrc)


{-| Converte tipo do erro em string de erro (útil para views).
-}
errorToString : Errors -> String
errorToString error =
    case error of
        BadRequest ->
            "Shit happened!"

        Unknown ->
            "Shit happened!1!!1!"



-- funções internas


{-| Encodifica payload do request.
-}
encoder : Network.ID -> Network.IP -> Value
encoder network targetIp =
    Encode.object
        [ ( "network_id", Encode.string <| network )
        , ( "ip", Encode.string <| targetIp )
        , ( "bounces", Encode.list [] )
        ]


{-| Decodifica resposta do request.
-}
receiver : FlagsSource a -> Code -> Value -> Data
receiver flagsSrc code value =
    case code of
        OkCode ->
            Ok ()

        _ ->
            value
                |> decodeValue errorMessage
                |> report "Processes.Bruteforce" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


{-| Converte a string de erro no tipo do erro.
-}
errorMessage : Decoder Errors
errorMessage =
    message <|
        \str ->
            case str of
                "bad_request" ->
                    succeed BadRequest

                value ->
                    fail <| commonError "download error message" value
