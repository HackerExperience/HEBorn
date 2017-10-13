module Game.Servers.Processes.Requests.Download
    exposing
        ( Response(..)
        , request
        , requestPublic
        , receive
        )

import Json.Decode as Decode
    exposing
        ( Decoder
        , Value
        , decodeValue
        , map
        , succeed
        , fail
        , string
        )
import Json.Decode.Pipeline as Encode
    exposing
        ( decode
        , required
        )
import Json.Encode as Encode
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (..)
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Filesystem.Shared exposing (FileID)
import Game.Network.Types exposing (NIP)


type Response
    = Okay ( FileID, String )
    | SelfLoop
    | FileNotFound
    | StorageFull
    | StorageNotFound
    | BadRequest


request : FileID -> String -> NIP -> ConfigSource a -> Cmd Msg
request fileId storageId nip =
    Requests.request (Topics.fsDownload nip)
        (DownloadRequest >> Request)
    <|
        encoder fileId storageId


requestPublic :
    FileID
    -> String
    -> NIP
    -> ConfigSource a
    -> Cmd Msg
requestPublic fileId storageId nip =
    Requests.request (Topics.fsPublicDownload nip)
        (DownloadRequest >> Request)
    <|
        encoder fileId storageId


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue decoder
                |> Result.map Okay
                |> Requests.report

        ErrorCode ->
            Requests.decodeGenericError
                json
                decodeErrorMessage
                |> Requests.report

        _ ->
            Nothing



-- INTERNALS


encoder : FileID -> String -> Value
encoder fileId storageId =
    Encode.object
        [ ( "file_id", Encode.string fileId )

        --, ( "storage_id", Encode.string storageId )
        ]


decoder : Decoder ( FileID, String )
decoder =
    decode (,)
        |> required "file_id" string
        |> required "storage_id" string


decodeErrorMessage : String -> Decoder Response
decodeErrorMessage str =
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

        _ ->
            fail "Unknown download request error message"
