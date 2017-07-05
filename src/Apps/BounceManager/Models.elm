module Apps.BounceManager.Models exposing (..)

import Apps.BounceManager.Menu.Models as Menu


type MainTab
    = TabManage
    | TabCreate


type alias BounceManager =
    { selected : MainTab }


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
    { selected = TabManage }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabManage ->
            "Manage"

        TabCreate ->
            "Create"
