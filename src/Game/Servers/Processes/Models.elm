module Game.Servers.Processes.Models exposing (..)

import Dict
import Utils
import Time exposing (Time)
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
    Time


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
    , fileID : Maybe FileID
    , version : Maybe Float
    , gatewayID : GatewayID
    , targetServerID : TargetServerID
    , networkID : NetworkID
    , connectionID : ConnectionID

    -- REVISE: USAGE WASN'T IMPLEMENTED YET
    , cpuUsage : Float
    , memusage : Float
    , downloadUsage : Float
    , uploadUsage : Float
    }


type alias Processes =
    Dict.Dict ProcessID Process


initialProcesses : Processes
initialProcesses =
    Dict.fromList
        -- DUMMY VALUE FOR PLAYING
        [ ( "dummy0000"
          , (Process "dummy0000" Cracker 1 (StateRunning 0) 0.5 (Just "dummym0") (Just 1.1) "me" "you" "san" "francisco" 1900000000 786000000 0 0)
          )
        , ( "dummy0001"
          , (Process "dummy0001" Decryptor 1 (StateRunning 0) 0.7 (Just "dummym1") (Just 2.0) "you" "me" "new" "york" 1900000000 786000000 512000 256000)
          )
        ]


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


resumeProcess : CompletionDate -> Processes -> Process -> Processes
resumeProcess completionDate processes process =
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
