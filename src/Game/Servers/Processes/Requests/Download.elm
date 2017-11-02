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
import Json.Encode as Encode
import Utils.Json.Decode exposing (commonError)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Decoders.Processes
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Filesystem.Shared exposing (FileID)
import Game.Servers.Processes.Models exposing (ID, Process)
import Game.Network.Types exposing (NIP)
import Game.Servers.Shared exposing (CId)


type Response
    = Okay ID Process
    | SelfLoop
    | FileNotFound
    | StorageFull
    | StorageNotFound
    | BadRequest


request :
    ID
    -> NIP
    -> FileID
    -> String
    -> CId
    -> ConfigSource a
    -> Cmd Msg
request optmistic target fileId storageId cid =
    Requests.request (Topics.fsDownload cid)
        (DownloadRequest optmistic >> Request)
    <|
        encoder target fileId storageId


requestPublic :
    ID
    -> NIP
    -> FileID
    -> String
    -> CId
    -> ConfigSource a
    -> Cmd Msg
requestPublic optmistic target fileId storageId cid =
    Requests.request (Topics.pftpDownload cid)
        (DownloadRequest optmistic >> Request)
    <|
        encoder target fileId storageId


receive : Code -> Value -> Maybe Response
receive code json =
    case code of
        OkCode ->
            json
                |> decodeValue Decoders.Processes.process
                |> Result.map (uncurry Okay)
                |> Requests.report

        ErrorCode ->
            Requests.decodeGenericError
                json
                decodeErrorMessage

        _ ->
            Nothing



-- INTERNALS


encoder : NIP -> FileID -> String -> Value
encoder ( netId, ip ) fileId storageId =
    Encode.object
        [ ( "network_id", Encode.string netId )
        , ( "ip", Encode.string ip )
        , ( "file_id", Encode.string fileId )

        {- STORAGE ISN'T IMPLEMENTED YET
           , ( "storage_id", Encode.string storageId )
        -}
        ]


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

        value ->
            fail <| commonError "download error message" value
