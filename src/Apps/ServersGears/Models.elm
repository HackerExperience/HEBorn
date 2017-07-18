module Apps.ServersGears.Models exposing (..)

import Apps.ServersGears.Menu.Models as Menu


type alias ServersGears =
    {}


type alias Model =
    { app : ServersGears
    , menu : Menu.Model
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
    { app = initialTemplate
    , menu = Menu.initialMenu
    }


initialTemplate : ServersGears
initialTemplate =
    {}
