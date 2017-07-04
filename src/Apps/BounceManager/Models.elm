module Apps.BounceManager.Models exposing (..)

import Apps.BounceManager.Menu.Models as Menu


type alias BounceManager =
    {}


type alias Model =
    { app : BounceManager
    , menu : Menu.Model
    }


name : String
name =
    "Bounce Manager"


title : Model -> String
title model =
    "Bounce Manager"


icon : String
icon =
    "bouncemngr"


initialModel : Model
initialModel =
    { app = initialBounceManager
    , menu = Menu.initialMenu
    }


initialBounceManager : BounceManager
initialBounceManager =
    {}
