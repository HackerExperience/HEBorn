module Game.Servers.Filesystem.Requests.Delete exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)


request : FileID -> CId -> ConfigSource a -> Cmd Msg
request fileId cid =
    let
        payload =
            Encode.object
                [ ( "fileId", Encode.string fileId ) ]
    in
        Requests.request (Topics.fsDelete cid)
            (DeleteRequest >> Request)
            payload
