module Game.Servers.Filesystem.Requests.Create exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics exposing (Topic(..))
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)


request : String -> String -> Location -> ID -> ConfigSource a -> Cmd Msg
request what newBaseName newLocation serverId =
    let
        destination =
            newLocation |> List.map Encode.string |> Encode.list

        payload =
            Encode.object
                [ ( "destination", destination )
                , ( "basename", Encode.string newBaseName )
                , ( "what", Encode.string what )
                ]
    in
        Requests.request ServerFileCreateTopic
            (CreateRequest >> Request)
            (Just serverId)
            payload
