module Apps.CtrlPanel.Models exposing (..)

import Apps.CtrlPanel.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
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
    { menu = Menu.initialMenu
    }
