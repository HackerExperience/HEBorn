module Game.Servers.Processes.Update exposing (update)

import Utils.React as React exposing (React)
import Random.Pcg as Random
import Events.Server.Handlers.ProcessCompleted as ProcessConclusion
import Events.Server.Handlers.ProcessBruteforceFailed as BruteforceFailed
import Events.Server.Handlers.ProcessesRecalcado as ProcessesChanged
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Shared exposing (CId)
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce exposing (bruteforceRequest)
import Game.Servers.Processes.Requests.Download as Download
    exposing
        ( publicDownloadRequest
        , privateDownloadRequest
        )
import Game.Servers.Processes.Requests.Upload as Upload exposing (uploadRequest)
import Game.Servers.Processes.Config exposing (..)
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Shared exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        DownloadRequestFailed id ->
            ( remove id model, React.none )

        HandleStartDownload origin storage id ->
            handleStartDownload config PrivateFTP origin storage id model

        HandleStartPublicDownload origin storage id ->
            handleStartDownload config PublicFTP origin storage id model

        HandleStartUpload target storage fileEntry ->
            handleStartUpload config target storage fileEntry model

        UploadRequestFailed id ->
            ( remove id model, React.none )

        BruteforceRequestFailed id ->
            ( remove id model, React.none )

        HandleStartBruteforce data ->
            handleStartBruteforce config data model

        HandleBruteforceFailed data ->
            handleBruteforceFailed data model

        HandleProcessConclusion data ->
            handleProcessConclusion data model

        HandleProcessesChanged data ->
            handleProcessesChanged config data model

        HandlePause id ->
            handlePause config id model

        HandleResume id ->
            handleResume config id model

        HandleRemove id ->
            handleRemove config id model



-- internals


handleStartDownload :
    Config msg
    -> TransferType
    -> NIP
    -> Download.StorageId
    -> Filesystem.FileEntry
    -> Model
    -> UpdateResponse msg
handleStartDownload config transferType origin storageId file model =
    let
        process =
            newOptimistic (Download (DownloadContent transferType storageId))
                config.nip
                (Network.getIp config.nip)
                unknownProcessFile

        ( id, model_ ) =
            insertOptimistic process model

        perform =
            case transferType of
                PublicFTP ->
                    publicDownloadRequest

                PrivateFTP ->
                    privateDownloadRequest

        toMsg result =
            case result of
                Ok () ->
                    config.onDownloadStarted storageId file

                Err error ->
                    config.batchMsg
                        [ config.toMsg <| DownloadRequestFailed id
                        , config.onGenericNotification
                            "Couldn't start download"
                            (Download.errorToString error)
                        ]

        cmd =
            config
                |> perform origin (Filesystem.toId file) storageId config.cid
                |> Cmd.map toMsg
                |> React.cmd
    in
        ( model_, cmd )


handleStartUpload :
    Config msg
    -> CId
    -> Upload.StorageId
    -> Filesystem.FileEntry
    -> Model
    -> UpdateResponse msg
handleStartUpload config target storageId file model =
    let
        process =
            newOptimistic (Upload (UploadContent (Just storageId)))
                config.nip
                (Network.getIp config.nip)
                unknownProcessFile

        ( id, model_ ) =
            insertOptimistic process model

        toMsg result =
            case result of
                Ok () ->
                    config.onUploadStarted storageId file

                Err error ->
                    config.batchMsg
                        [ config.toMsg <| UploadRequestFailed id
                        , config.onGenericNotification
                            "Couldn't start upload"
                            (Upload.errorToString error)
                        ]

        cmd =
            config
                |> uploadRequest (Filesystem.toId file) storageId target
                |> Cmd.map toMsg
                |> React.cmd
    in
        ( model_, cmd )


handleStartBruteforce :
    Config msg
    -> Network.IP
    -> Model
    -> UpdateResponse msg
handleStartBruteforce config target model =
    let
        process =
            newOptimistic Cracker config.nip target unknownProcessFile

        ( id, model_ ) =
            insertOptimistic process model

        tid =
            process
                |> getTarget
                |> Network.getId

        tip =
            process
                |> getTarget
                |> Network.getIp

        toMsg result =
            case result of
                Ok () ->
                    config.onBruteforceStarted

                Err error ->
                    config.batchMsg
                        [ config.toMsg <| BruteforceRequestFailed id
                        , config.onGenericNotification
                            "Couldn't start bruteforce"
                            (Bruteforce.errorToString error)
                        ]

        cmd =
            config
                |> bruteforceRequest tid tip config.cid
                |> Cmd.map toMsg
                |> React.cmd
    in
        ( model_, cmd )


handleBruteforceFailed : BruteforceFailed.Data -> Model -> UpdateResponse msg
handleBruteforceFailed data model =
    let
        update process =
            model
                |> insert data.processId
                    (whenStarted (conclude (Just False)) process)
                |> flip (,) React.none
    in
        updateOrSync update data.processId model


handleProcessConclusion : ProcessConclusion.Data -> Model -> UpdateResponse msg
handleProcessConclusion id model =
    let
        update process =
            model
                |> insert id (whenStarted (conclude (Just True)) process)
                |> flip (,) React.none
    in
        updateOrSync update id model


handleProcessesChanged :
    Config msg
    -> ProcessesChanged.Data
    -> Model
    -> UpdateResponse msg
handleProcessesChanged config processes model =
    ( { model | processes = processes, lastModified = config.lastTick }
    , React.none
    )


handlePause : Config msg -> ID -> Model -> UpdateResponse msg
handlePause config id model =
    let
        update process =
            model
                |> insert id (whenStarted pause process)
                |> flip (,) React.none
    in
        updateOrSync update id model


handleResume : Config msg -> ID -> Model -> UpdateResponse msg
handleResume config id model =
    let
        update process =
            model
                |> insert id (whenStarted resume process)
                |> flip (,) React.none
    in
        updateOrSync update id model


handleRemove : Config msg -> ID -> Model -> UpdateResponse msg
handleRemove config id model =
    ( remove id model, React.none )



-- helpers


{-| Applies the function to the process when it's found, (should) requests
a bootstrap otherwise.
-}
updateOrSync :
    (Process -> UpdateResponse msg)
    -> ID
    -> Model
    -> UpdateResponse msg
updateOrSync func id model =
    case get id model of
        Just process ->
            func process

        Nothing ->
            ( model, React.none )
