module Apps.Explorer.Config exposing (..)

import Game.Servers.Models as Servers
import Game.Servers.Shared exposing (CId)
import Apps.Explorer.Menu.Config as Menu
import Apps.Explorer.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , activeServer : Servers.Server
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig { toMsg, activeServer } =
    { toMsg = MenuMsg >> toMsg
    , activeServer = activeServer
    }
