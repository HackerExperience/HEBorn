module Game.Servers.Processes.Types.Shared exposing (..)

import Game.Shared exposing (ID)
import Game.Servers.Filesystem.Models as Filesystem exposing (FileID)


type alias FileID =
    Filesystem.FileID


type Scope
    = Local
    | Global


type alias ProcessID =
    ID


type alias ServerID =
    ID


type alias ConnectionID =
    ID


type alias TargetFileID =
    FileID


type alias TargetLogID =
    String


type alias LogMessage =
    String


type alias GatewayID =
    ServerID


type alias TargetServerID =
    ServerID


type alias NetworkID =
    String
