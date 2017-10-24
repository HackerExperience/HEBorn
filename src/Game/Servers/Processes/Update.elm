module Game.Servers.Processes.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Server.Processes.Started as ProcessStarted
import Events.Server.Processes.Conclusion as ProcessConclusion
import Events.Server.Processes.BruteforceFailed as BruteforceFailed
import Events.Server.Processes.Changed as ProcessesChanged
import Game.Models as Game
import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Processes.Messages exposing (Msg(..))
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Processes.Requests exposing (..)
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Game.Network.Types as Network exposing (NIP)
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models as Notifications


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Model
    -> CId
    -> Msg
    -> Model
    -> UpdateResponse
update game cid msg model =
    let
        nip =
            game
                |> Game.getServers
                |> Servers.getNIP cid
    in
        case msg of
            Pause id ->
                onPause game id model

            Resume id ->
                onResume game id model

            Remove id ->
                onRemove game id model

            Start type_ target file ->
                onStart game
                    cid
                    (newOptimistic type_ nip target (newProcessFile file))
                    model

            StartBruteforce target ->
                onStart game
                    cid
                    (newOptimistic Cracker nip target unknownProcessFile)
                    model

            StartDownload origin fileId storageId ->
                onDownload game
                    cid
                    (newOptimistic
                        (Download (DownloadContent PrivateFTP storageId))
                        nip
                        (Network.getIp nip)
                        unknownProcessFile
                    )
                    origin
                    fileId
                    model

            StartPublicDownload origin fileId storageId ->
                onDownload game
                    cid
                    (newOptimistic
                        (Download (DownloadContent PublicFTP storageId))
                        nip
                        (Network.getIp nip)
                        unknownProcessFile
                    )
                    origin
                    fileId
                    model

            Complete id ->
                onComplete game id model

            Request data ->
                updateRequest game cid (receive data) model

            HandleProcessStarted data ->
                handleProcessStarted data model

            HandleProcessConclusion data ->
                handleProcessConclusion data model

            HandleBruteforceFailed data ->
                handleBruteforceFailed data model

            HandleProcessesChanged data ->
                handleProcessesChanged data model

            HandleBruteforceSuccess id ->
                handleBruteforceSuccess id model



-->>>>>>> Refactor Servers.CId to finally be the union it always should've been.
-- internals


{-| Applies the function to the process when it's found, (should) requests
a bootstrap otherwise.
-}
updateOrSync :
    (Process -> UpdateResponse)
    -> ID
    -> Model
    -> UpdateResponse
updateOrSync func id model =
    case get id model of
        Just process ->
            func process

        Nothing ->
            -- TODO: add sync request here
            Update.fromModel model



-- processes messages


onPause : Game.Model -> ID -> Model -> UpdateResponse
onPause game id model =
    let
        update process =
            model
                |> upsert id (pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


onResume : Game.Model -> ID -> Model -> UpdateResponse
onResume game id model =
    let
        update process =
            model
                |> upsert id (resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


onRemove : Game.Model -> ID -> Model -> UpdateResponse
onRemove game id model =
    let
        model_ =
            remove id model
    in
        Update.fromModel model_


onStart : Game.Model -> CId -> Process -> Model -> UpdateResponse
onStart game cid process model =
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
                        Bruteforce.request id tid tip cid game
                in
                    ( model_, cmd, Dispatch.none )

            _ ->
                Update.fromModel model_


onDownload :
    Game.Model
    -> CId
    -> Process
    -> NIP
    -> Filesystem.ForeignFileBox
    -> Model
    -> UpdateResponse
onDownload game cid process origin file model =
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
                                    file.id
                                    storageId
                                    cid
                                    game

                            PrivateFTP ->
                                Download.request id
                                    origin
                                    file.id
                                    storageId
                                    cid
                                    game

                    dispatch =
                        Notifications.DownloadStarted origin file
                            |> Notifications.create
                            |> Notifications.Insert game.meta.lastTick
                            |> Dispatch.serverNotification cid
                in
                    ( model_, cmd, dispatch )

            _ ->
                Update.fromModel model_


onComplete :
    Game.Model
    -> ID
    -> Model
    -> UpdateResponse
onComplete game id model =
    let
        update process =
            model
                |> upsert id (conclude Nothing process)
                |> Update.fromModel
    in
        updateOrSync update id model



-- request handlers


updateRequest :
    Game.Model
    -> CId
    -> Maybe Response
    -> Model
    -> UpdateResponse
updateRequest game cid response model =
    case response of
        Just (Bruteforce oldId response) ->
            onBruteforceRequest game cid oldId response model

        Just (DownloadingFile oldId response) ->
            onDownloadRequest game cid oldId response model

        Nothing ->
            Update.fromModel model


onBruteforceRequest :
    Game.Model
    -> CId
    -> ID
    -> Bruteforce.Response
    -> Model
    -> UpdateResponse
onBruteforceRequest game cid oldId response model =
    case response of
        Bruteforce.Okay id process ->
            let
                model_ =
                    replace oldId id process model
            in
                Update.fromModel model_


onDownloadRequest :
    Game.Model
    -> CId
    -> ID
    -> Download.Response
    -> Model
    -> UpdateResponse
onDownloadRequest game cid oldId response model =
    case response of
        Download.Okay id process ->
            okDownloadFile id oldId process cid model

        Download.SelfLoop ->
            failDownloadFile game.meta.lastTick cid oldId model <|
                "Self download: use copy instead!"

        Download.FileNotFound ->
            failDownloadFile game.meta.lastTick cid oldId model <|
                "The file you're trying to download no longer exists"

        Download.StorageFull ->
            failDownloadFile game.meta.lastTick cid oldId model <|
                "Not enougth space!"

        Download.StorageNotFound ->
            failDownloadFile game.meta.lastTick cid oldId model <|
                "The storage you're trying to access no longer exists"

        Download.BadRequest ->
            failDownloadFile game.meta.lastTick cid oldId model <|
                "Shit happened!"



-- event handlers


handleProcessStarted : ProcessStarted.Data -> Model -> UpdateResponse
handleProcessStarted ( id, process ) model =
    model
        |> insert id process
        |> Update.fromModel


handlePauseEvent : ID -> Model -> UpdateResponse
handlePauseEvent id model =
    let
        update process =
            model
                |> upsert id (pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


handleResumeEvent : ID -> Model -> UpdateResponse
handleResumeEvent id model =
    let
        update process =
            model
                |> upsert id (resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


handleRemoveEvent : ID -> Model -> UpdateResponse
handleRemoveEvent id model =
    model
        |> remove id
        |> Update.fromModel


handleProcessConclusion : ProcessConclusion.Data -> Model -> UpdateResponse
handleProcessConclusion id model =
    let
        update process =
            model
                |> upsert id (conclude (Just True) process)
                |> Update.fromModel
    in
        updateOrSync update id model


handleBruteforceFailed : BruteforceFailed.Data -> Model -> UpdateResponse
handleBruteforceFailed data model =
    let
        update process =
            model
                |> upsert data.processId
                    (conclude (Just False) process)
                |> Update.fromModel
    in
        updateOrSync update data.processId model


handleProcessesChanged : ProcessesChanged.Data -> Model -> UpdateResponse
handleProcessesChanged processes model =
    Update.fromModel { model | processes = processes }


handleBruteforceSuccess : ID -> Model -> UpdateResponse
handleBruteforceSuccess id model =
    -- TODO: dispatch from password acquired after implementing "dispatch
    -- to servers of following nip"
    Update.fromModel model



-- request responses


failDownloadFile : Float -> CId -> ID -> Model -> String -> UpdateResponse
failDownloadFile lastTick cid oldId model message =
    let
        dispatch =
            message
                |> Notifications.Simple "Impossible to start download"
                |> Notifications.create
                |> Notifications.Insert lastTick
                |> Dispatch.serverNotification cid

        model_ =
            remove oldId model
    in
        ( model_, Cmd.none, dispatch )


okDownloadFile : ID -> ID -> Process -> CId -> Model -> UpdateResponse
okDownloadFile id oldId process cid model =
    model
        |> replace oldId id process
        |> Update.fromModel
