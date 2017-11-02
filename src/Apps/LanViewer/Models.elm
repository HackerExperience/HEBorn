module Apps.LanViewer.Models exposing (..)

import Apps.LanViewer.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    }


name : String
name =
    "Lan Viewer"


title : Model -> String
title model =
    "Lan Viewer"


icon : String
icon =
    "lanvw"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    }
