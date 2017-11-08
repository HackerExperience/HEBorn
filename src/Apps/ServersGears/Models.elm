module Apps.ServersGears.Models exposing (..)

import Apps.ServersGears.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    }


name : String
name =
    "Servers Gears"


title : Model -> String
title model =
    "Servers Gears"


icon : String
icon =
    "srvgr"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    }
