module Events.Servers.Filesystem exposing (Event(..), handler)

import Utils.Events exposing (Handler, notify)
import Json.Decode exposing (Decoder, decodeValue)
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Shared as Filesystem exposing (..)
import Game.Servers.Filesystem.Models exposing (..)
import Decoders.Filesystem


type Event
    = Newfile Decoders.Filesystem.IndexEntry


handler : String -> Handler Event
handler event json =
    case event of
        "new_file" ->
            onNewFile json

        _ ->
            Nothing



-- internals


onNewFile : Handler Event
onNewFile json =
    decodeValue (Decoders.Filesystem.entry ()) json
        |> Result.map Newfile
        |> notify
