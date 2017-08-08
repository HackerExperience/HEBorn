module Game.Servers.Filesystem.Messages exposing (..)

import Game.Servers.Filesystem.Shared exposing (FileID, FilePath, Location)
import Requests.Types exposing (ResponseType)


type Msg
    = Delete FileID
    | CreateTextFile FilePath
    | CreateEmptyDir FilePath
    | Move FileID Location
    | Rename FileID String
    | Request RequestMsg


type RequestMsg
    = DeleteRequest ResponseType
    | RenameRequest ResponseType
    | MoveRequest ResponseType
    | CreateRequest ResponseType
    | IndexRequest ResponseType
