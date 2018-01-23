module Game.Servers.Filesystem.Messages exposing (..)

import Requests.Types exposing (ResponseType)
import Game.Servers.Filesystem.Shared exposing (..)


type Msg
    = HandleDelete Id
    | HandleRename Id String
    | HandleNewTextFile Path Name
    | HandleNewDir Path Name
    | HandleMove Id Path
    | HandleAdded Id File
