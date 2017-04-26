module Game.Servers.Processes.Models exposing (..)

import Dict
import Utils
import Game.Servers.Filesystem.Models exposing (FileID)
import Game.Shared exposing (ID)


type alias ProcessID =
    ID


type alias ServerID =
    ID


type alias ConnectionID =
    ID


type ProcessType
    = Cracker
    | Decryptor
    | Encryptor
    | FileDownload
    | LogDeleter


type alias CompletionDate =
    Float


type ProcessState
    = StateRunning CompletionDate
    | StateStandby
    | StatePaused
    | StateComplete


type alias ProcessPriority =
    Int


type alias Progress =
    Float


type alias GatewayID =
    ServerID


type alias TargetServerID =
    ServerID


{-| FIXME: export NetworkID from Game.Network.Models
-}
type alias NetworkID =
    String


type alias Process =
    { id : ProcessID
    , processType : ProcessType
    , priority : ProcessPriority
    , state : ProcessState
    , progress : Progress
    , fileID : FileID
    , gatewayID : GatewayID
    , targetServerID : TargetServerID
    , networkID : NetworkID
    , connectionID : ConnectionID
    }


type alias Processes =
    Dict.Dict ProcessID Process


initialProcesses : Processes
initialProcesses =
    Dict.empty


{-| REVIEW: this doesn't look that useful
-}
getProcessID : Process -> ProcessID
getProcessID process =
    process.id


getProcessByID : ProcessID -> Processes -> Maybe Process
getProcessByID id processes =
    Dict.get id processes


processExists : ProcessID -> Processes -> Bool
processExists id processes =
    Dict.member id processes


addProcess : Process -> Processes -> Processes
addProcess process processes =
    Dict.insert process.id process processes


removeProcess : Process -> Processes -> Processes
removeProcess process processes =
    Dict.remove process.id processes


pauseProcess : Process -> Processes -> Processes
pauseProcess process processes =
    case process.state of
        StatePaused ->
            processes

        _ ->
            let
                process_ =
                    { process | state = StatePaused }
            in
                Utils.safeUpdateDict processes process_.id process_


resumeProcess : Process -> CompletionDate -> Processes -> Processes
resumeProcess process completionDate processes =
    case process.state of
        StateRunning _ ->
            processes

        _ ->
            let
                process_ =
                    { process | state = StateRunning completionDate }
            in
                Utils.safeUpdateDict processes process_.id process_


completeProcess : Process -> Processes -> Processes
completeProcess process processes =
    case process.state of
        StateComplete ->
            processes

        _ ->
            let
                process_ =
                    { process | state = StateComplete }
            in
                Utils.safeUpdateDict processes process_.id process_
