module Apps.Bug.Models exposing (..)

import Apps.Bug.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    }


name : String
name =
    "The bug"


title : Model -> String
title model =
    "Bugtura"


icon : String
icon =
    "bug"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    }
