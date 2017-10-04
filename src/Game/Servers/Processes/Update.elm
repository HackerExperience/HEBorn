module Game.Servers.Processes.Update exposing (update)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ServerEvent), ServerEvent(ProcessesEvent))
import Events.Servers.Processes as Processes exposing (Event(..))
import Game.Models as Game
import Game.Servers.Processes.Messages exposing (Msg(..))
import Game.Servers.Processes.Models exposing (..)
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Requests exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Model
    -> ServerID
    -> Msg
    -> Model
    -> UpdateResponse
update game serverId msg model =
    case msg of
        Pause id ->
            onPause game
                serverId
                id
                model

        Resume id ->
            onResume game serverId id model

        Remove id ->
            onRemove game serverId id model

        Start type_ origin target file ->
            onStart
                game
                serverId
                (newOptimistic type_ origin target <| newProcessFile file)
                model

        StartBruteforce target ->
            onStart
                game
                serverId
                (newOptimistic Cracker serverId target unknownProcessFile)
                model

        Complete id ->
            onComplete game serverId id model

        Request data ->
            updateRequest game serverId (receive data) model

        Event event ->
            updateEvent game serverId event model



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


onPause : Game.Model -> ServerID -> ID -> Model -> UpdateResponse
onPause game serverId id model =
    let
        update process =
            model
                |> upsert id (pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


onResume : Game.Model -> ServerID -> ID -> Model -> UpdateResponse
onResume game serverId id model =
    let
        update process =
            model
                |> upsert id (resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


onRemove : Game.Model -> ServerID -> ID -> Model -> UpdateResponse
onRemove game serverId id model =
    let
        model_ =
            remove id model
    in
        Update.fromModel model_


onStart : Game.Model -> ServerID -> Process -> Model -> UpdateResponse
onStart game serverId process model =
    let
        ( id, model_ ) =
            insertOptimistic process model
    in
        case getType process of
            Cracker ->
                let
                    cmd =
                        Bruteforce.request id
                            (getTarget process)
                            serverId
                            game
                in
                    ( model_, cmd, Dispatch.none )

            _ ->
                Update.fromModel model_


onComplete :
    Game.Model
    -> ServerID
    -> ID
    -> Model
    -> UpdateResponse
onComplete game serverId id model =
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
    -> ServerID
    -> Events.Event
    -> Model
    -> UpdateResponse
updateEvent game serverId event model =
    case event of
        ServersEvent (ServerEvent _ (ProcessesEvent event)) ->
            updateProcessesEvent game serverId event model

        _ ->
            Update.fromModel model


updateProcessesEvent :
    Game.Model
    -> ServerID
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
    -> ServerID
    -> ID
    -> Process
    -> Model
    -> UpdateResponse
onStartedEvent game serverId id process model =
    model
        |> insert id process
        |> Update.fromModel


onPauseEvent :
    Game.Model
    -> ServerID
    -> ID
    -> Model
    -> UpdateResponse
onPauseEvent game serverId id model =
    let
        update process =
            model
                |> upsert id (pause process)
                |> Update.fromModel
    in
        updateOrSync update id model


onResumeEvent :
    Game.Model
    -> ServerID
    -> ID
    -> Model
    -> UpdateResponse
onResumeEvent game serverId id model =
    let
        update process =
            model
                |> upsert id (resume process)
                |> Update.fromModel
    in
        updateOrSync update id model


onCompleteEvent :
    Game.Model
    -> ServerID
    -> ID
    -> Model
    -> UpdateResponse
onCompleteEvent game serverId id model =
    let
        update process =
            model
                |> upsert id (conclude (Just True) process)
                |> Update.fromModel
    in
        updateOrSync update id model


onRemoveEvent :
    Game.Model
    -> ServerID
    -> ID
    -> Model
    -> UpdateResponse
onRemoveEvent game serverId id model =
    model
        |> remove id
        |> Update.fromModel


onBruteforceFailedEvent :
    Game.Model
    -> ServerID
    -> Processes.BruteforceFailedData
    -> Model
    -> UpdateResponse
onBruteforceFailedEvent game serverId response model =
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
    -> ServerID
    -> Maybe Response
    -> Model
    -> UpdateResponse
updateRequest game serverId response model =
    case response of
        Just (Bruteforce oldId response) ->
            onBruteforceRequest game serverId oldId response model

        Nothing ->
            Update.fromModel model


onBruteforceRequest :
    Game.Model
    -> ServerID
    -> ID
    -> Bruteforce.Response
    -> Model
    -> UpdateResponse
onBruteforceRequest game serverId oldId response model =
    case response of
        Bruteforce.Okay id process ->
            let
                model_ =
                    replace oldId id process model
            in
                Update.fromModel model_
