module Apps.LanViewer.Models exposing (..)

import Apps.LanViewer.Menu.Models as Menu


type alias LanViewer =
    {}


type alias Model =
    { app : LanViewer
    , menu : Menu.Model
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
    { app = initialLanViewer
    , menu = Menu.initialMenu
    }


initialLanViewer : LanViewer
initialLanViewer =
    {}
