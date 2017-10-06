module Game.Servers.Filesystem.Requests.Create exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)
import Game.Network.Types exposing (NIP)


-- FIXME: this API is weird


request : String -> String -> Location -> NIP -> ConfigSource a -> Cmd Msg
request what newBaseName newLocation nip =
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
        Requests.request (Topics.fsCreate nip)
            (CreateRequest >> Request)
            payload
