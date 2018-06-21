module Game.Servers.Processes.Requests.Upload
    exposing
        ( Data
        , Errors(..)
        , FileId
        , StorageId
        , uploadRequest
        , errorToString
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        )


{-| Contém requests de upload de arquivo.
-}
import Json.Encode as Encode
import Utils.Json.Decode exposing (commonError, message)
import Requests.Requests as Requests exposing (report)
import Requests.Topics as Topics
import Requests.Types exposing (Code(..), FlagsSource)
import Game.Servers.Shared exposing (CId)


{-| Resultado do request, não é um Maybe pois o tratamento de sucesso pode
ser interessante um dia e a falta de typeclasses do elm nos forçaria a
reescrever tudo se deixarmos pra mudar o tipo depois.
-}
type alias Data =
    Result Errors ()


{-| Tipos de erros que podem ocorrer ao realizar o request:

    - SelfLoop: download forma loop
    - FileNotFound: arquivo não encontrado
    - StorageFull: storage alvo está cheia
    - StorageNotFound: storage alvo não existe
    - BadRequest: request mal formado
    - Unknown: erro desconhecido pelo client

-}
type Errors
    = SelfLoop
    | FileNotFound
    | StorageFull
    | StorageNotFound
    | BadRequest
    | Unknown


{-| Id do arquivo a ser baixado.
-}
type alias FileId =
    String


{-| Id da storage que vai armazenar arquivo.
-}
type alias StorageId =
    String


{-| Cria um Cmd de request para enviar um arquivo para outro servidor.
-}
uploadRequest :
    FileId
    -> StorageId
    -> CId
    -> FlagsSource a
    -> Cmd Data
uploadRequest fileId storageId cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.fsUpload cid)
            (encoder fileId storageId)
        |> Cmd.map (uncurry <| receiver flagsSrc)


{-| Converte tipo do erro em string de erro (útil para views).
-}
errorToString : Errors -> String
errorToString error =
    case error of
        SelfLoop ->
            "Self upload: use copy instead!"

        FileNotFound ->
            "The file you're trying to upload no longer exists"

        StorageFull ->
            "Not enougth space!"

        StorageNotFound ->
            "The storage you're trying to access no longer exists"

        BadRequest ->
            "Shit happened!"

        Unknown ->
            "Shit happened!1!!1!"



-- internals


{-| Encodifica payload do request.
-}
encoder : FileId -> String -> Value
encoder fileId storageId =
    Encode.object
        [ ( "file_id", Encode.string fileId )
        , ( "storage_id", Encode.string storageId )
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
                |> report "Processes.Upload" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


{-| Converte a string de erro no tipo do erro.
-}
errorMessage : Decoder Errors
errorMessage =
    message <|
        \str ->
            case str of
                "upload_self" ->
                    succeed SelfLoop

                "bad_request" ->
                    succeed BadRequest

                "file_not_found" ->
                    succeed FileNotFound

                "storage_full" ->
                    succeed StorageFull

                "storage_not_found" ->
                    succeed StorageNotFound

                value ->
                    fail <| commonError "upload error message" value
