module Game.Servers.Processes.Types.Local exposing (..)

import Time exposing (Time)
import Game.Servers.Processes.Types.Shared exposing (..)


type alias Version =
    Float


type alias CompletionDate =
    -- NOW + ((OBJECTIVE - PROCESSED) / ALOCATED) -- IN UTC TIMESTAMP
    Time


type alias ProcessPriority =
    -- 0..5 - DEFAULT: 3
    Int


type alias Progress =
    -- PROCESSED / OBJECTIVE -- 0..1
    Float


type ProcessState
    = StateRunning
    | StateStandby --MIGHT BE REMOVED
    | StatePaused
    | StateComplete


type ProcessType
    = Cracker Version
    | Decryptor Version TargetFileID Scope
    | Encryptor Version TargetFileID
    | FileTransference TargetFileID
    | LogForge Version TargetLogID LogMessage
    | PassiveFirewall Version


type alias ProcessProp =
    { processType : ProcessType
    , priority : ProcessPriority
    , state : ProcessState
    , eta : Maybe CompletionDate
    , progress : Maybe Progress
    , fileID : Maybe FileID
    , gatewayID : GatewayID
    , targetServerID : TargetServerID
    , networkID : Maybe NetworkID
    , connectionID : Maybe ConnectionID
    , cpuUsage : Int
    , memusage : Int
    , downloadUsage : Int
    , uploadUsage : Int
    }
