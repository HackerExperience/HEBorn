module Game.Servers.Filesystem.Requests.Move exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)
import Game.Network.Types exposing (NIP)


request : Location -> FileID -> NIP -> ConfigSource a -> Cmd Msg
request newLocation fileId nip =
    let
        destination =
            newLocation |> List.map Encode.string |> Encode.list

        payload =
            Encode.object
                [ ( "fileId", Encode.string fileId )
                , ( "destination", destination )
                ]
    in
        Requests.request (Topics.fsMove nip)
            (MoveRequest >> Request)
            payload
