module Apps.Browser.Config exposing (..)

import Game.Servers.Shared exposing (CId)
import Apps.Browser.Menu.Config as Menu
import Game.Servers.Models as Servers
import Apps.Browser.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , endpoints : Maybe (List CId)
    , activeServer : Servers.Server
    , batchMsg : List msg -> msg
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig config =
    { toMsg = MenuMsg >> config.toMsg
    , batchMsg = config.batchMsg
    }
