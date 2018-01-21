module Apps.Browser.Config exposing (..)

import Game.Servers.Shared exposing (CId)
import Apps.Browser.Menu.Config as Menu
import Game.Servers.Models as Servers
import Apps.Browser.Messages exposing (..)


type alias Config msg =
    { toMsg : Msg -> msg
    , endpoints : Maybe (List CId)
    , activeServer : Servers.Server
    }


menuConfig : Config msg -> Menu.Config msg
menuConfig { toMsg } =
    { toMsg = MenuMsg >> toMsg }
