module Game.Servers.Processes.Models exposing (..)

import Dict
import Utils
import Game.Servers.Filesystem.Models exposing (FileID)
import Game.Network.Models exposing (ConnectionID)
import Game.Servers.Models exposing (ServerID)
import Game.Shared exposing (ID)


type alias ProcessID =
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


getProcessByID : Processes -> ProcessID -> Maybe Process
getProcessByID processes id =
    Dict.get id processes


processExists : Processes -> ProcessID -> Bool
processExists processes id =
    Dict.member id processes


addProcess : Processes -> Process -> Processes
addProcess processes process =
    Dict.insert process.id process processes


removeProcess : Processes -> Process -> Processes
removeProcess processes process =
    Dict.remove process.id processes


pauseProcess : Processes -> Process -> Processes
pauseProcess processes process =
    case process.state of
        StatePaused ->
            processes

        _ ->
            let
                process_ =
                    { process | state = StatePaused }
            in
                Utils.safeUpdateDict processes process_.id process_


resumeProcess : Processes -> Process -> CompletionDate -> Processes
resumeProcess processes process completionDate =
    case process.state of
        StateRunning _ ->
            processes

        _ ->
            let
                process_ =
                    { process | state = StateRunning completionDate }
            in
                Utils.safeUpdateDict processes process_.id process_


completeProcess : Processes -> Process -> Processes
completeProcess processes process =
    case process.state of
        StateComplete ->
            processes

        _ ->
            let
                process_ =
                    { process | state = StateComplete }
            in
                Utils.safeUpdateDict processes process_.id process_
