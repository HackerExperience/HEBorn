module Game.Servers.Processes.Requests.Download
    exposing
        ( Data
        , Errors(..)
        , FileId
        , StorageId
        , privateDownloadRequest
        , publicDownloadRequest
        , errorToString
        )

{-| Contém requests de download de arquivo de servidores invadidos e ftp
público.
-}

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , succeed
        , fail
        )
import Json.Encode as Encode
import Utils.Json.Decode exposing (commonError, message)
import Game.Meta.Types.Network exposing (NIP)
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

    - SelfLoop

Download forma loop.

    - FileNotFound

Arquivo não encontrado.

    - StorageFull

Storage alvo está cheia.

    - StorageNotFound

Storage alvo não existe.

    - BadRequest

Request mal formado.

    - Unknown

Erro desconhecido pelo client.

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


{-| Cria um Cmd de request para baixar um arquivo privado.
-}
privateDownloadRequest :
    NIP
    -> FileId
    -> StorageId
    -> CId
    -> FlagsSource a
    -> Cmd Data
privateDownloadRequest target fileId storageId cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.fsDownload cid)
            (encoder target fileId storageId)
        |> Cmd.map (uncurry <| receiver flagsSrc)


{-| Cria um Cmd de request para baixar um arquivo de um ftp público.
-}
publicDownloadRequest :
    NIP
    -> FileId
    -> StorageId
    -> CId
    -> FlagsSource a
    -> Cmd Data
publicDownloadRequest target fileId storageId cid flagsSrc =
    flagsSrc
        |> Requests.request (Topics.pftpDownload cid)
            (encoder target fileId storageId)
        |> Cmd.map (uncurry <| receiver flagsSrc)


{-| Converte tipo do erro em string de erro (útil para views).
-}
errorToString : Errors -> String
errorToString error =
    case error of
        SelfLoop ->
            "Self download: use copy instead!"

        FileNotFound ->
            "The file you're trying to download no longer exists"

        StorageFull ->
            "Not enougth space!"

        StorageNotFound ->
            "The storage you're trying to access no longer exists"

        BadRequest ->
            "Shit happened!"

        Unknown ->
            "Shit happened!1!!1!"



-- funções internas


{-| Encodifica payload do request.
-}
encoder : NIP -> FileId -> String -> Value
encoder ( netId, ip ) fileId storageId =
    Encode.object
        [ ( "network_id", Encode.string netId )
        , ( "ip", Encode.string ip )
        , ( "file_id", Encode.string fileId )
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
                |> report "Processes.Download" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


{-| Converte a string de erro no tipo do erro.
-}
errorMessage : Decoder Errors
errorMessage =
    message <|
        \str ->
            case str of
                "download_self" ->
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
                    fail <| commonError "download error message" value
