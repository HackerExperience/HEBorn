module Apps.BounceManager.Models exposing (..)


type MainTab
    = TabManage
    | TabCreate


type alias Model =
    { selected : MainTab
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
    { selected = TabManage
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabManage ->
            "Manage"

        TabCreate ->
            "Create"
