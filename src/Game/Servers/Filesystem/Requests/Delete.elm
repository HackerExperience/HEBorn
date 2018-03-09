module Game.Servers.Filesystem.Requests.Delete exposing (deleteRequest)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), ResponseType)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Shared exposing (..)


deleteRequest : Id -> CId -> FlagsSource a -> Cmd ResponseType
deleteRequest id cid =
    Requests.request (Topics.fsDelete cid)
        (encoder id)



-- internals


encoder : Id -> Value
encoder id =
    Encode.object
        [ ( "file_id", Encode.string id ) ]
