module Apps.CtrlPanel.Models exposing (..)

import Apps.CtrlPanel.Menu.Models as Menu


type alias CtrlPanel =
    {}


type alias Model =
    { app : CtrlPanel
    , menu : Menu.Model
    }


name : String
name =
    "Control Panel"


title : Model -> String
title model =
    "Control Panel"


icon : String
icon =
    "cpanel"


initialModel : Model
initialModel =
    { app = initialTemplate
    , menu = Menu.initialMenu
    }


initialTemplate : CtrlPanel
initialTemplate =
    {}
