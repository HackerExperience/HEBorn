module Game.Servers.Filesystem.Requests.Rename exposing (..)

import Json.Encode as Encode exposing (Value)
import Requests.Requests as Requests
import Requests.Topics as Topics
import Requests.Types exposing (ConfigSource, Code(..))
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Messages exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)
import Game.Network.Types exposing (NIP)


request : String -> FileID -> NIP -> ConfigSource a -> Cmd Msg
request newBaseName fileId nip =
    let
        payload =
            Encode.object
                [ ( "fileId", Encode.string fileId )
                , ( "basename", Encode.string newBaseName )
                ]
    in
        Requests.request (Topics.fsRename nip)
            (RenameRequest >> Request)
            payload
