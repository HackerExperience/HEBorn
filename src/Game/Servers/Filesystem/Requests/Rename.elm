module Game.Servers.Filesystem.Requests.Rename exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared exposing (..)


request : String -> Id -> CId -> FlagsSource a -> Cmd Msg
request newBaseName id cid =
    let
        payload =
            Encode.object
                [ ( "file_id", Encode.string id )
                , ( "basename", Encode.string newBaseName )
                ]
    in
        Requests.request (Topics.fsRename cid)
            (RenameRequest >> Request)
            payload
