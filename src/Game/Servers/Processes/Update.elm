module Game.Servers.Processes.Update exposing (update)

import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Notifications.Models as Notifications
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce exposing (bruteforceRequest)
import Game.Servers.Processes.Requests.Download as Download
    exposing
        ( publicDownloadRequest
        , privateDownloadRequest
        )
import Game.Servers.Processes.Config exposing (..)
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Processes.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        DownloadRequestFailed id ->
            ( remove id model, Cmd.none )

        HandleStartDownload origin storage id ->
            handleStartDownload config PrivateFTP origin storage id model

        HandleStartPublicDownload origin storage id ->
            handleStartDownload config PublicFTP origin storage id model

        BruteforceRequestFailed id ->
            ( remove id model, Cmd.none )

        HandleStartBruteforce data ->
            handleStartBruteforce config data model

        HandleBruteforceFailed data ->
            handleBruteforceFailed data model

        HandleProcessStarted data ->
            handleProcessStarted data model

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

        HandleComplete id ->
            handleComplete config id model

        Start type_ target file ->
            handleStart config
                (newOptimistic type_ config.nip target (newProcessFile file))
                model



-- internals


handleStartDownload :
    Config msg
    -> TransferType
    -> NIP
    -> Download.StorageId
    -> Download.FileId
    -> Model
    -> UpdateResponse msg
handleStartDownload config transferType origin storage file model =
    let
        process =
            newOptimistic (Download (DownloadContent transferType storage))
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
                    config.batchMsg []

                Err error ->
                    config.batchMsg
                        [ config.toMsg <| DownloadRequestFailed id
                        , error
                            |> Download.errorToString
                            |> Notifications.Simple "Couldn't start download"
                            |> config.notifyServer
                        ]

        cmd =
            config
                |> perform origin file storage config.cid
                |> Cmd.map toMsg
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
                    config.batchMsg []

                Err () ->
                    config.toMsg <| BruteforceRequestFailed id

        cmd =
            config
                |> bruteforceRequest tid tip config.cid
                |> Cmd.map toMsg
    in
        ( model_, cmd )


handleBruteforceFailed : BruteforceFailed.Data -> Model -> UpdateResponse msg
handleBruteforceFailed data model =
    let
        update process =
            model
                |> insert data.processId
                    (whenStarted (conclude (Just False)) process)
                |> flip (,) Cmd.none
    in
        updateOrSync update data.processId model


handleProcessStarted : ProcessStarted.Data -> Model -> UpdateResponse msg
handleProcessStarted ( id, process ) model =
    model
        |> insert id process
        |> flip (,) Cmd.none


handleProcessConclusion : ProcessConclusion.Data -> Model -> UpdateResponse msg
handleProcessConclusion id model =
    let
        update process =
            model
                |> insert id (whenStarted (conclude (Just True)) process)
                |> flip (,) Cmd.none
    in
        updateOrSync update id model


handleProcessesChanged :
    Config msg
    -> ProcessesChanged.Data
    -> Model
    -> UpdateResponse msg
handleProcessesChanged config processes model =
    ( { model | processes = processes, lastModified = config.lastTick }
    , Cmd.none
    )


handlePause : Config msg -> ID -> Model -> UpdateResponse msg
handlePause config id model =
    let
        update process =
            model
                |> insert id (whenStarted pause process)
                |> flip (,) Cmd.none
    in
        updateOrSync update id model


handleResume : Config msg -> ID -> Model -> UpdateResponse msg
handleResume config id model =
    let
        update process =
            model
                |> insert id (whenStarted resume process)
                |> flip (,) Cmd.none
    in
        updateOrSync update id model


handleRemove : Config msg -> ID -> Model -> UpdateResponse msg
handleRemove config id model =
    ( remove id model, Cmd.none )


handleComplete :
    Config msg
    -> ID
    -> Model
    -> UpdateResponse msg
handleComplete config id model =
    let
        update process =
            model
                |> insert id (whenStarted (conclude Nothing) process)
                |> flip (,) Cmd.none
    in
        updateOrSync update id model


handleStart : Config msg -> Process -> Model -> UpdateResponse msg
handleStart config process model =
    -- to be deprecated
    let
        ( id, model_ ) =
            insertOptimistic process model
    in
        case getType process of
            Cracker ->
                let
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
                                config.batchMsg []

                            Err () ->
                                config.toMsg <| BruteforceRequestFailed id

                    cmd =
                        config
                            |> bruteforceRequest tid tip config.cid
                            |> Cmd.map toMsg
                in
                    ( model_, cmd )

            _ ->
                ( model_, Cmd.none )



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
            ( model, Cmd.none )
