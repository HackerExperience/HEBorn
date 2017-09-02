module Game.Servers.Processes.Update exposing (..)

import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Events.Events as Events exposing (Event(ServersEvent))
import Events.Servers exposing (Event(ServerEvent), ServerEvent(ProcessesEvent))
import Events.Servers.Processes as Processes exposing (Event(..))
import Game.Models as Game
import Game.Servers.Processes.Messages exposing (Msg(..))
import Game.Servers.Processes.Models
    exposing
        ( Processes
        , ProcessProp
        , pauseProcess
        , resumeProcess
        , removeProcess
        , addProcess
        )
import Game.Servers.Processes.Types.Shared exposing (ProcessID)
import Game.Servers.Processes.ResultHandler exposing (completeProcess)


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

        Event (ServersEvent (ServerEvent serverId (ProcessesEvent event))) ->
            onEvent serverId event model

        Event _ ->
            Update.fromModel model


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


onEvent : String -> Processes.Event -> Processes -> UpdateResponse
onEvent serverId event model =
    case event of
        Changed ->
            Update.fromModel model

        Started data ->
            Update.fromModel model

        Conclusion processId ->
            completeProcess serverId model processId
                |> \( m, d ) -> ( m, Cmd.none, d )
