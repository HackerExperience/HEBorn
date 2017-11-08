module Apps.ConnManager.Models exposing (..)

import Apps.ConnManager.Menu.Models as Menu


type Sorting
    = DefaultSort


type alias Model =
    { menu : Menu.Model
    , filterText : String
    , filterFlags : List Never
    , filterCache : List String
    , sorting : Sorting
    }


name : String
name =
    "Connection Manager"


title : Model -> String
title model =
    "Connection Manager"


icon : String
icon =
    "connmngr"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    , filterText = ""
    , filterFlags = []
    , filterCache = []
    , sorting = DefaultSort
    }
