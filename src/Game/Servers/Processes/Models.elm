module Game.Servers.Processes.Models exposing (..)

import Dict
import Utils.Dict as DictUtils
import Game.Servers.Processes.Types.Shared exposing (..)
import Game.Servers.Processes.Types.Local as Local exposing (ProcessState(..))
import Game.Servers.Processes.Types.Remote as Remote


type ProcessProp
    = LocalProcess Local.ProcessProp
    | RemoteProcess Remote.ProcessProp


type alias Processes =
    Dict.Dict ProcessID ProcessProp


initialProcesses : Processes
initialProcesses =
    Dict.empty


getProcess : ProcessID -> Processes -> Maybe ProcessProp
getProcess =
    Dict.get


processExists : ProcessID -> Processes -> Bool
processExists =
    Dict.member


addProcess : ProcessID -> ProcessProp -> Processes -> Processes
addProcess =
    Dict.insert


removeProcess : ProcessID -> Processes -> Processes
removeProcess =
    Dict.remove


setLocalProcessState : Local.ProcessState -> Local.ProcessProp -> Local.ProcessProp
setLocalProcessState newState process =
    { process | state = newState }


doLocalProcess : (Local.ProcessProp -> Local.ProcessProp) -> ProcessID -> Processes -> ( Processes, Maybe Local.ProcessProp )
doLocalProcess job pId processes =
    case getProcess pId processes of
        Just (LocalProcess prop) ->
            let
                prop_ =
                    job prop

                model_ =
                    DictUtils.safeUpdate pId (LocalProcess prop_) processes
            in
                ( model_, Just prop_ )

        _ ->
            ( processes, Nothing )


pauseProcess : ProcessID -> Processes -> Processes
pauseProcess pId model =
    model
        |> doLocalProcess (setLocalProcessState StatePaused) pId
        |> Tuple.first


resumeProcess : ProcessID -> Processes -> Processes
resumeProcess pId model =
    model
        |> doLocalProcess (setLocalProcessState StateRunning) pId
        |> Tuple.first


completeProcess : ProcessID -> Processes -> ( Processes, Maybe Local.ProcessProp )
completeProcess pId model =
    doLocalProcess (setLocalProcessState StateComplete) pId model
