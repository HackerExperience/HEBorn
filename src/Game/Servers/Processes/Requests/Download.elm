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


type alias Data =
    Result Errors ()


type Errors
    = SelfLoop
    | FileNotFound
    | StorageFull
    | StorageNotFound
    | BadRequest
    | Unknown


type alias FileId =
    String


type alias StorageId =
    String


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



-- internals


encoder : NIP -> FileId -> String -> Value
encoder ( netId, ip ) fileId storageId =
    Encode.object
        [ ( "network_id", Encode.string netId )
        , ( "ip", Encode.string ip )
        , ( "file_id", Encode.string fileId )
        , ( "storage_id", Encode.string storageId )
        ]


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
