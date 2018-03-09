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


encoder : FileId -> String -> Value
encoder fileId storageId =
    Encode.object
        [ ( "file_id", Encode.string fileId )
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
                |> report "Processes.Upload" code flagsSrc
                |> Result.mapError (always Unknown)
                |> Result.andThen Err


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
