module Game.Servers.Processes.Update exposing (..)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ServerEvent), ServerEvent(ProcessesEvent))
import Events.Servers.Processes as Processes exposing (Event(..))
import Game.Models as Game
import Game.Servers.Processes.Requests.Bruteforce as Bruteforce
import Game.Servers.Processes.Messages exposing (Msg(..))
import Game.Servers.Processes.Models
    exposing
        ( Processes
        , ProcessProp(..)
        , pauseProcess
        , resumeProcess
        , removeProcess
        , addProcess
        )
import Game.Servers.Processes.Types.Shared exposing (ProcessID)
import Game.Servers.Processes.ResultHandler exposing (completeProcess)
import Game.Servers.Processes.Requests exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (ProcessState(..))
import Game.Servers.Processes.Types.Remote as Remote


type alias UpdateResponse =
    ( Processes, Cmd Msg, Dispatch )


update :
    Game.Model
    -> Msg
    -> Processes
    -> UpdateResponse
update game msg model =
    case msg of
        Pause processId ->
            onPause processId model

        Resume processId ->
            onResume processId model

        Complete processId ->
            onComplete game processId model

        Remove processId ->
            onRemove processId model

        Create process ->
            onCreate process model

        Request data ->
            onRequest game (receive data) model

        Event (ServersEvent (ServerEvent serverId (ProcessesEvent event))) ->
            updateEvent game serverId event model

        Event _ ->
            Update.fromModel model



-- internals


onPause : ProcessID -> Processes -> UpdateResponse
onPause processId model =
    processId
        |> flip pauseProcess model
        |> Update.fromModel


onResume : ProcessID -> Processes -> UpdateResponse
onResume processId model =
    processId
        |> flip resumeProcess model
        |> Update.fromModel


onComplete : Game.Model -> ProcessID -> Processes -> UpdateResponse
onComplete game processId model =
    -- TODO: pass serverId down instead
    case Game.getActiveServer game of
        Just ( serverId, _ ) ->
            completeProcess serverId model processId
                |> \( m, d ) -> ( m, Cmd.none, d )

        _ ->
            Update.fromModel model


onRemove : ProcessID -> Processes -> UpdateResponse
onRemove processId model =
    processId
        |> flip removeProcess model
        |> Update.fromModel


onCreate : ( ProcessID, ProcessProp ) -> Processes -> UpdateResponse
onCreate ( pId, prop ) model =
    Update.fromModel <| addProcess pId prop model


onRequest : Game.Model -> Maybe Response -> Processes -> UpdateResponse
onRequest game response model =
    case response of
        Just response ->
            updateRequest game response model

        Nothing ->
            Update.fromModel model


updateRequest : Game.Model -> Response -> Processes -> UpdateResponse
updateRequest game response model =
    case response of
        Bruteforce data ->
            onBruteforce game data model


updateEvent : Game.Model -> String -> Processes.Event -> Processes -> UpdateResponse
updateEvent game serverId event model =
    case event of
        Started _ ->
            Update.fromModel model

        Changed ->
            Update.fromModel model

        Conclusion processId ->
            onConclusion game serverId processId model


onBruteforce :
    Game.Model
    -> Bruteforce.Response
    -> Processes
    -> UpdateResponse
onBruteforce game data model =
    -- TODO: fixme, the whole process model is wrong
    case data of
        Bruteforce.Okay data ->
            let
                process =
                    LocalProcess
                        (Local.ProcessProp
                            (Local.Cracker 0)
                            3
                            StateRunning
                            (Just game.meta.lastTick)
                            (Just 0)
                            Nothing
                            "gateway0"
                            "gateway0"
                            Nothing
                            Nothing
                            100000
                            32000
                            0
                            0
                        )
            in
                addProcess data.processId process model
                    |> Update.fromModel


onStarted :
    Game.Model
    -> String
    -> Processes.StartedData
    -> Processes
    -> UpdateResponse
onStarted game serverId data model =
    -- TODO: fixme, the whole process model is wrong
    let
        process =
            LocalProcess
                (Local.ProcessProp
                    (Local.Cracker 0)
                    3
                    StateRunning
                    (Just game.meta.lastTick)
                    (Just 0)
                    Nothing
                    "gateway0"
                    "gateway0"
                    Nothing
                    Nothing
                    100000
                    32000
                    0
                    0
                )
    in
        addProcess data.processId process model
            |> Update.fromModel


onConclusion :
    Game.Model
    -> String
    -> String
    -> Processes
    -> UpdateResponse
onConclusion game serverId processId model =
    completeProcess serverId model processId
        |> \( m, d ) -> ( m, Cmd.none, d )
