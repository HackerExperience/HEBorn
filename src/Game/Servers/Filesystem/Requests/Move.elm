module Game.Servers.Filesystem.Requests.Move exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Models exposing (..)


request : Path -> Id -> CId -> ConfigSource a -> Cmd Msg
request path id cid =
    let
        destination =
            -- TODO: sending a flat string may be better
            path
                |> List.map Encode.string
                |> Encode.list

        payload =
            Encode.object
                [ ( "file_id", Encode.string id )
                , ( "destination", destination )
                ]
    in
        Requests.request (Topics.fsMove cid)
            (MoveRequest >> Request)
            payload
