module Game.Servers.Processes.Update exposing (..)

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

        Start t origin target version file ->
            onStart
                game
                serverId
                (newOptimistic t origin target version file)
                model

        Complete id ->
            onComplete game serverId id model

        --onRemove processId model
        Request data ->
            Update.fromModel model

        Event event ->
            updateEvent game serverId event model



-- internals


updateOrSync :
    (Process -> UpdateResponse)
    -> ID
    -> Model
    -> UpdateResponse
updateOrSync f id model =
    case get id model of
        Just process ->
            f process

        Nothing ->
            -- TODO: add sync request here
            Update.fromModel model


dummyProcess : String -> ServerID -> ServerID -> Process
dummyProcess t origin target =
    let
        type_ =
            typeFromName t
                |> Maybe.withDefault Cracker
    in
        { type_ = type_
        , access =
            Full
                { origin = origin
                , priority = Normal
                , usage =
                    { cpu = ( 0.0, "" )
                    , ram = ( 0.0, "" )
                    , downlink = ( 0.0, "" )
                    , uplink = ( 0.0, "" )
                    }
                , connection = Nothing
                }
        , state = Starting
        , version = Nothing
        , progress = ( 0.0, Nothing )
        , file = Nothing
        , target = target
        }



-- event routers


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
        Started data ->
            onStartedEvent game
                serverId
                data.processId
                (dummyProcess data.type_ serverId serverId)
                model

        Conclusion id ->
            onCompleteEvent game serverId id Nothing model

        BruteforceFailed data ->
            onBruteforceFailedEvent game serverId data model



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
                |> upsert id (complete Nothing process)
                |> Update.fromModel
    in
        updateOrSync update id model



-- process event handlers


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
    -> Maybe Status
    -> Model
    -> UpdateResponse
onCompleteEvent game serverId id status model =
    let
        update process =
            model
                |> upsert id (complete status process)
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
                |> upsert response.processId (complete Nothing process)
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
        Just (Bruteforce data) ->
            onBruteforceRequest game serverId data model

        Nothing ->
            Update.fromModel model


onBruteforceRequest :
    Game.Model
    -> ServerID
    -> Bruteforce.Response
    -> Model
    -> UpdateResponse
onBruteforceRequest game serverId response model =
    case response of
        Bruteforce.Okay data ->
            let
                process =
                    dummyProcess data.type_ serverId data.targetIp

                model_ =
                    insert data.processId process model
            in
                Update.fromModel model_
