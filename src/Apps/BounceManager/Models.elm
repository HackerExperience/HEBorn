module Apps.BounceManager.Models exposing (..)

import Apps.BounceManager.Menu.Models as Menu


type MainTab
    = TabManage
    | TabCreate


type alias Model =
    { menu : Menu.Model
    , selected : MainTab
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
    { menu = Menu.initialMenu
    , selected = TabManage
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabManage ->
            "Manage"

        TabCreate ->
            "Create"
