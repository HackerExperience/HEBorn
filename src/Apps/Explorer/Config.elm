module Apps.Explorer.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Apps.Explorer.Menu.Config as Menu
import Apps.Explorer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeServer : Servers.Server
    , batchMsg : List msg -> msg
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig config =
    { toMsg = MenuMsg >> config.toMsg
    , activeServer = config.activeServer
    , batchMsg = config.batchMsg
    }
