module Game.Servers.Processes.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ProcessesEvent))
import Events.Servers.Processes as Processes exposing (Event(..))
import Game.Models as Game
import Game.Servers.Messages as Servers
import Game.Servers.Processes.Messages exposing (Msg(..))
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Requests.Download as Download
import Game.Servers.Processes.Requests exposing (..)
import Game.Network.Types as Network exposing (NIP)
import Game.Notifications.Messages as Notifications
import Game.Notifications.Models as Notifications


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Model
    -> NIP
    -> Msg
    -> Model
    -> UpdateResponse
update game nip msg model =
    case msg of
        Pause id ->
            onPause game nip id model

        Resume id ->
            onResume game nip id model

        Remove id ->
            onRemove game nip id model

        Start type_ target file ->
            onStart game
                nip
                (newOptimistic type_ nip target <| newProcessFile file)
                model

        StartBruteforce target ->
            onStart game
                nip
                (newOptimistic Cracker nip target unknownProcessFile)
                model

        StartDownload source fileId storageId ->
            onStart game
                nip
                (newOptimistic
                    (Download False
                        storageId
                        fileId
                    )
                    source
                    (Tuple.second nip)
                    unknownProcessFile
                )
                model

        StartPublicDownload source fileId storageId ->
            onStart game
                nip
                (newOptimistic
                    (Download True
                        storageId
                        fileId
                    )
                    source
                    (Tuple.second nip)
                    unknownProcessFile
                )
                model

        Complete id ->
            onComplete game nip id model

        Request data ->
            updateRequest game nip (receive data) model

        Event event ->
            updateEvent game nip event model



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


onPause : Game.Model -> NIP -> ID -> Model -> UpdateResponse
onPause game nip id model =
    let
        update process =
            model
                |> upsert id (pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


onResume : Game.Model -> NIP -> ID -> Model -> UpdateResponse
onResume game nip id model =
    let
        update process =
            model
                |> upsert id (resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


onRemove : Game.Model -> NIP -> ID -> Model -> UpdateResponse
onRemove game nip id model =
    let
        model_ =
            remove id model
    in
        Update.fromModel model_


onStart : Game.Model -> NIP -> Process -> Model -> UpdateResponse
onStart game nip process model =
    let
        ( id, model_ ) =
            insertOptimistic process model
    in
        case getType process of
            Cracker ->
                let
                    targetIp =
                        process
                            |> getTarget
                            |> Network.getIp

                    cmd =
                        Bruteforce.request id nip targetIp game
                in
                    ( model_, cmd, Dispatch.none )

            Download isPublic fileId storageId ->
                let
                    cmd =
                        if isPublic then
                            Download.requestPublic id fileId storageId nip game
                        else
                            Download.request id fileId storageId nip game
                in
                    ( model_, cmd, Dispatch.none )

            _ ->
                Update.fromModel model_


onComplete :
    Game.Model
    -> NIP
    -> ID
    -> Model
    -> UpdateResponse
onComplete game nip id model =
    let
        update process =
            model
                |> upsert id (conclude Nothing process)
                |> Update.fromModel
    in
        updateOrSync update id model



-- process event routers


updateEvent :
    Game.Model
    -> NIP
    -> Events.Event
    -> Model
    -> UpdateResponse
updateEvent game serverId event model =
    case event of
        ServersEvent _ (ProcessesEvent event) ->
            updateProcessesEvent game serverId event model

        _ ->
            Update.fromModel model


updateProcessesEvent :
    Game.Model
    -> NIP
    -> Processes.Event
    -> Model
    -> UpdateResponse
updateProcessesEvent game serverId event model =
    case event of
        Changed processes ->
            onChangedEvent processes model

        Started ( id, process ) ->
            onStartedEvent game serverId id process model

        Conclusion id ->
            onCompleteEvent game serverId id model

        BruteforceFailed data ->
            onBruteforceFailedEvent game serverId data model



-- process event handlers


onChangedEvent :
    Processes
    -> Model
    -> UpdateResponse
onChangedEvent processes model =
    Update.fromModel { model | processes = processes }


onStartedEvent :
    Game.Model
    -> NIP
    -> ID
    -> Process
    -> Model
    -> UpdateResponse
onStartedEvent game nip id process model =
    model
        |> insert id process
        |> Update.fromModel


onPauseEvent :
    Game.Model
    -> NIP
    -> ID
    -> Model
    -> UpdateResponse
onPauseEvent game nip id model =
    let
        update process =
            model
                |> upsert id (pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


onResumeEvent :
    Game.Model
    -> NIP
    -> ID
    -> Model
    -> UpdateResponse
onResumeEvent game nip id model =
    let
        update process =
            model
                |> upsert id (resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


onCompleteEvent :
    Game.Model
    -> NIP
    -> ID
    -> Model
    -> UpdateResponse
onCompleteEvent game nip id model =
    let
        update process =
            model
                |> upsert id (conclude (Just True) process)
                |> Update.fromModel
    in
        updateOrSync update id model


onRemoveEvent :
    Game.Model
    -> NIP
    -> ID
    -> Model
    -> UpdateResponse
onRemoveEvent game nip id model =
    model
        |> remove id
        |> Update.fromModel


onBruteforceFailedEvent :
    Game.Model
    -> NIP
    -> Processes.BruteforceFailedData
    -> Model
    -> UpdateResponse
onBruteforceFailedEvent game nip response model =
    let
        update process =
            model
                |> upsert response.processId
                    (conclude (Just False) process)
                |> Update.fromModel
    in
        updateOrSync update response.processId model



-- request handlers


updateRequest :
    Game.Model
    -> NIP
    -> Maybe Response
    -> Model
    -> UpdateResponse
updateRequest game nip response model =
    case response of
        Just (Bruteforce oldId response) ->
            onBruteforceRequest game nip oldId response model

        Just (DownloadingFile oldId response) ->
            onDownloadingFile game nip oldId response model

        Nothing ->
            Update.fromModel model


onBruteforceRequest :
    Game.Model
    -> NIP
    -> ID
    -> Bruteforce.Response
    -> Model
    -> UpdateResponse
onBruteforceRequest game nip oldId response model =
    case response of
        Bruteforce.Okay id process ->
            let
                model_ =
                    replace oldId id process model
            in
                Update.fromModel model_


onDownloadingFile :
    Game.Model
    -> NIP
    -> ID
    -> Download.Response
    -> Model
    -> UpdateResponse
onDownloadingFile game nip oldId response model =
    case response of
        Download.Okay id process ->
            okDownloadFile id
                process
                game.meta.lastTick
                nip
                oldId
                model

        Download.SelfLoop ->
            failDownloadFile game.meta.lastTick nip oldId model <|
                "Self download: use copy instead!"

        Download.FileNotFound ->
            failDownloadFile game.meta.lastTick nip oldId model <|
                "The file you're trying to download no longer exists"

        Download.StorageFull ->
            failDownloadFile game.meta.lastTick nip oldId model <|
                "Not enougth space!"

        Download.StorageNotFound ->
            failDownloadFile game.meta.lastTick nip oldId model <|
                "The storage you're trying to access no longer exists"

        Download.BadRequest ->
            failDownloadFile game.meta.lastTick nip oldId model <|
                "Shit happened!"


failDownloadFile : Float -> NIP -> ID -> Model -> String -> UpdateResponse
failDownloadFile lastTick nip oldId model message =
    let
        dispatch =
            message
                |> Notifications.Simple "Impossible to start download"
                |> Notifications.create
                |> Notifications.Insert lastTick
                |> Dispatch.serverNotification nip

        model_ =
            remove oldId model
    in
        ( model_, Cmd.none, dispatch )


okDownloadFile : ID -> Process -> Float -> NIP -> ID -> Model -> UpdateResponse
okDownloadFile id process lastTick nip oldId model =
    let
        dispatch =
            Notifications.DownloadStarted
                |> Notifications.create
                |> Notifications.Insert lastTick
                |> Dispatch.serverNotification nip

        model_ =
            replace oldId id process model
    in
        ( model_, Cmd.none, dispatch )
