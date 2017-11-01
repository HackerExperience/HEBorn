module Game.Servers.Filesystem.Messages exposing (..)

import Game.Servers.Filesystem.Shared exposing (FileID, FilePath, Location)
import Requests.Types exposing (ResponseType)


type Msg
    = HandleDelete FileID
    | HandleRename FileID String
    | HandleNewTextFile FilePath
    | HandleNewDir FilePath
    | HandleMove FileID Location
    | Request RequestMsg


type RequestMsg
    = SyncRequest ResponseType
    | DeleteRequest ResponseType
    | RenameRequest ResponseType
    | MoveRequest ResponseType
    | CreateRequest ResponseType
    | IndexRequest ResponseType
