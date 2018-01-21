module Apps.ConnManager.Config exposing (..)

import Game.Servers.Models as Servers
import Apps.ConnManager.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeServer : Servers.Server
    }
