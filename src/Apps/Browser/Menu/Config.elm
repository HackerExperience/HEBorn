module Apps.Browser.Menu.Config exposing (..)

import Game.Servers.Filesystem.Shared as Filesystem
import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId, StorageId)
import Apps.Browser.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , batchMsg : List msg -> msg
    }
