module Apps.Finance.Models exposing (..)

import Apps.Finance.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    }


name : String
name =
    "Finance"


title : Model -> String
title model =
    "Finance"


icon : String
icon =
    "moneymngr"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    }
