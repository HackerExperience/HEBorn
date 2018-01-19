module Game.Servers.Filesystem.Requests.Create exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..))
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Models exposing (..)


-- FIXME: this API is weird


request :
    String
    -> String
    -> Path
    -> CId
    -> FlagsSource a
    -> Cmd Msg
request what newBaseName newPath cid =
    let
        destination =
            -- TODO: sending a flat string may be better
            newPath
                |> List.map Encode.string
                |> Encode.list

        payload =
            Encode.object
                [ ( "destination", destination )
                , ( "basename", Encode.string newBaseName )
                , ( "what", Encode.string what )
                ]
    in
        Requests.request (Topics.fsCreate cid)
            (CreateRequest >> Request)
            payload
