module Game.Servers.Filesystem.Requests.Delete exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Models exposing (..)


request : Id -> CId -> FlagsSource a -> Cmd Msg
request id cid =
    let
        payload =
            Encode.object
                [ ( "file_id", Encode.string id ) ]
    in
        Requests.request (Topics.fsDelete cid)
            (DeleteRequest >> Request)
            payload
