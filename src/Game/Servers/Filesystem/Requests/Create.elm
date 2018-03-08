module Game.Servers.Filesystem.Requests.Create exposing (createRequest)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (FlagsSource, Code(..), ResponseType)
import Game.Servers.Shared exposing (CId)
import Game.Servers.Filesystem.Shared exposing (..)


createRequest :
    String
    -> String
    -> Path
    -> CId
    -> FlagsSource a
    -> Cmd ResponseType
createRequest what newBaseName newPath cid =
    Requests.request (Topics.fsCreate cid)
        (encoder what newBaseName newPath)



-- internals


encoder : String -> String -> Path -> Value
encoder what newBaseName newPath =
    let
        -- TODO: sending a flat string may be better
        destination =
            newPath
                |> List.map Encode.string
                |> Encode.list
    in
        Encode.object
            [ ( "destination", destination )
            , ( "basename", Encode.string newBaseName )
            , ( "what", Encode.string what )
            ]
