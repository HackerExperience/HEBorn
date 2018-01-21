module Apps.Explorer.Menu.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Apps.Explorer.Menu.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeServer : Servers.Server
    }
