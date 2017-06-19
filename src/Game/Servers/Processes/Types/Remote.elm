module Game.Servers.Processes.Types.Remote exposing (..)

import Game.Servers.Processes.Types.Shared exposing (..)


type ProcessType
    = Cracker
    | Decryptor TargetFileID Scope
    | Encryptor TargetFileID
    | FileTransference TargetFileID
    | LogForge TargetLogID


type alias ProcessProp =
    -- ALWAYS RUNNING
    { processType : ProcessType
    , gatewayID : GatewayID --NOT ALWAYS GATEWAY
    , networkID : Maybe NetworkID
    , connectionID : Maybe ConnectionID
    }
