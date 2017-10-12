module Events.Servers.Filesystem exposing (Event(..), handler)

import Utils.Events exposing (Handler, notify)
import Json.Decode exposing (decodeValue, lazy)
import Game.Servers.Shared exposing (..)
import Game.Servers.Filesystem.Shared exposing (Foreigner)
import Decoders.Filesystem exposing (entry)


type Event
    = Newfile Foreigner


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
    decodeValue (lazy entry) json
        |> Result.map Newfile
        |> notify
