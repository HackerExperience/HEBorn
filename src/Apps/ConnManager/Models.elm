module Apps.ConnManager.Models exposing (..)

import Apps.ConnManager.Menu.Models as Menu


type alias ConnManager =
    {}


type alias Model =
    { app : ConnManager
    , menu : Menu.Model
    }


name : String
name =
    "Connection Manager"


title : Model -> String
title model =
    "Connection Manager"


icon : String
icon =
    "connmngr"


initialModel : Model
initialModel =
    { app = initialConnManager
    , menu = Menu.initialMenu
    }


initialConnManager : ConnManager
initialConnManager =
    {}
