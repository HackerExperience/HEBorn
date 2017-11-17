module Game.Servers.Filesystem.Messages exposing (..)

import Game.Servers.Filesystem.Models exposing (..)
import Requests.Types exposing (ResponseType)


type Msg
    = HandleDelete Id
    | HandleRename Id String
    | HandleNewTextFile Path Name
    | HandleNewDir Path Name
    | HandleMove Id Path
    | HandleAdded Id File
    | Request RequestMsg


type RequestMsg
    = DeleteRequest ResponseType
    | RenameRequest ResponseType
    | MoveRequest ResponseType
    | CreateRequest ResponseType
    | IndexRequest ResponseType
