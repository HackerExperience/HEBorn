module Game.Servers.Processes.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Notifications as Notifications
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged
import Game.Meta.Types.Network as Network exposing (NIP)
import Game.Notifications.Models as Notifications
import Game.Servers.Filesystem.Models as Filesystem
import Game.Servers.Shared as Servers exposing (CId)
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Processes.Config exposing (..)
import Game.Servers.Processes.Messages exposing (..)
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Requests exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update :
    Config msg
    -> Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        HandlePause id ->
            handlePause config id model

        HandleResume id ->
            handleResume config id model

        HandleRemove id ->
            handleRemove config id model

        Start type_ target file ->
            handleStart config
                (newOptimistic type_ config.nip target (newProcessFile file))
                model

        HandleStartBruteforce target ->
            handleStart config
                (newOptimistic Cracker config.nip target unknownProcessFile)
                model

        HandleStartDownload origin storageId fileId ->
            handleDownload config
                (newOptimistic
                    (Download (DownloadContent PrivateFTP storageId))
                    config.nip
                    (Network.getIp config.nip)
                    unknownProcessFile
                )
                origin
                fileId
                model

        HandleStartPublicDownload origin storageId fileId ->
            handleDownload config
                (newOptimistic
                    (Download (DownloadContent PublicFTP storageId))
                    config.nip
                    (Network.getIp config.nip)
                    unknownProcessFile
                )
                origin
                fileId
                model

        HandleComplete id ->
            onComplete config id model

        HandleProcessStarted data ->
            handleProcessStarted data model

        HandleProcessConclusion data ->
            handleProcessConclusion data model

        HandleBruteforceFailed data ->
            handleBruteforceFailed data model

        HandleProcessesChanged data ->
            handleProcessesChanged config data model

        HandleBruteforceSuccess id ->
            handleBruteforceSuccess id model

        Request data ->
            updateRequest config (receive data) model



-- internals


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
            Update.fromModel model



-- processes messages


handlePause : Config msg -> ID -> Model -> UpdateResponse msg
handlePause config id model =
    let
        update process =
            model
                |> insert id (whenStarted pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


handleResume : Config msg -> ID -> Model -> UpdateResponse msg
handleResume config id model =
    let
        update process =
            model
                |> insert id (whenStarted resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


handleRemove : Config msg -> ID -> Model -> UpdateResponse msg
handleRemove config id model =
    let
        model_ =
            remove id model
    in
        Update.fromModel model_


handleStart : Config msg -> Process -> Model -> UpdateResponse msg
handleStart config process model =
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

                    cmd =
                        config
                            |> Bruteforce.request id tid tip config.cid
                            |> Cmd.map config.toMsg
                in
                    ( model_, cmd, Dispatch.none )

            _ ->
                Update.fromModel model_


handleDownload :
    Config msg
    -> Process
    -> NIP
    -> Filesystem.FileEntry
    -> Model
    -> UpdateResponse msg
handleDownload config process origin file model =
    let
        ( id, model_ ) =
            insertOptimistic process model
    in
        case getType process of
            Download { transferType, storageId } ->
                let
                    cmd =
                        case transferType of
                            PublicFTP ->
                                Download.requestPublic id
                                    origin
                                    (Filesystem.toId file)
                                    storageId
                                    config.cid
                                    config

                            PrivateFTP ->
                                Download.request id
                                    origin
                                    (Filesystem.toId file)
                                    storageId
                                    config.cid
                                    config

                    cmd_ =
                        Cmd.map config.toMsg cmd
                in
                    ( model_, cmd_, Dispatch.none )

            _ ->
                Update.fromModel model_


onComplete :
    Config msg
    -> ID
    -> Model
    -> UpdateResponse msg
onComplete config id model =
    let
        update process =
            model
                |> insert id (whenStarted (conclude Nothing) process)
                |> Update.fromModel
    in
        updateOrSync update id model



-- request handlers


updateRequest :
    Config msg
    -> Maybe Response
    -> Model
    -> UpdateResponse msg
updateRequest config response model =
    case response of
        Just (Bruteforce oldId response) ->
            onBruteforceRequest config oldId response model

        Just (DownloadingFile oldId response) ->
            onDownloadRequest config oldId response model

        Nothing ->
            Update.fromModel model


onBruteforceRequest :
    Config msg
    -> ID
    -> Bruteforce.Response
    -> Model
    -> UpdateResponse msg
onBruteforceRequest config oldId response model =
    case response of
        Bruteforce.Okay ->
            Update.fromModel model


onDownloadRequest :
    Config msg
    -> ID
    -> Download.Response
    -> Model
    -> UpdateResponse msg
onDownloadRequest config oldId response model =
    case response of
        Download.Okay ->
            Update.fromModel model

        Download.SelfLoop ->
            failDownloadFile config.lastTick config.cid oldId model <|
                "Self download: use copy instead!"

        Download.FileNotFound ->
            failDownloadFile config.lastTick config.cid oldId model <|
                "The file you're trying to download no longer exists"

        Download.StorageFull ->
            failDownloadFile config.lastTick config.cid oldId model <|
                "Not enougth space!"

        Download.StorageNotFound ->
            failDownloadFile config.lastTick config.cid oldId model <|
                "The storage you're trying to access no longer exists"

        Download.BadRequest ->
            failDownloadFile config.lastTick config.cid oldId model <|
                "Shit happened!"



-- event handlers


handleProcessStarted : ProcessStarted.Data -> Model -> UpdateResponse msg
handleProcessStarted ( id, process ) model =
    model
        |> insert id process
        |> Update.fromModel


handleProcessConclusion : ProcessConclusion.Data -> Model -> UpdateResponse msg
handleProcessConclusion id model =
    let
        update process =
            model
                |> insert id (whenStarted (conclude (Just True)) process)
                |> Update.fromModel
    in
        updateOrSync update id model


handleBruteforceFailed : BruteforceFailed.Data -> Model -> UpdateResponse msg
handleBruteforceFailed data model =
    let
        update process =
            model
                |> insert data.processId
                    (whenStarted (conclude (Just False)) process)
                |> Update.fromModel
    in
        updateOrSync update data.processId model


handleProcessesChanged :
    Config msg
    -> ProcessesChanged.Data
    -> Model
    -> UpdateResponse msg
handleProcessesChanged config processes model =
    Update.fromModel <|
        { model | processes = processes, lastModified = config.lastTick }


handleBruteforceSuccess : ID -> Model -> UpdateResponse msg
handleBruteforceSuccess id model =
    -- TODO: dispatch from password acquired after implementing "dispatch
    -- to servers of following nip"
    Update.fromModel model



-- request responses


failDownloadFile : Float -> CId -> ID -> Model -> String -> UpdateResponse msg
failDownloadFile lastTick cid oldId model message =
    let
        dispatch =
            message
                |> Notifications.Simple "Impossible to start download"
                |> Notifications.NotifyServer cid Nothing
                |> Dispatch.notifications

        model_ =
            remove oldId model
    in
        ( model_, Cmd.none, Dispatch.none )
