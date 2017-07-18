module Apps.Template.Models exposing (..)

import Apps.Template.Menu.Models as Menu


type alias Template =
    {}


type alias Model =
    { app : Template
    , menu : Menu.Model
    }


name : String
name =
    "Template App"


title : Model -> String
title model =
    "Template Title"


icon : String
icon =
    "templateico"


initialModel : Model
initialModel =
    { app = initialTemplate
    , menu = Menu.initialMenu
    }


initialTemplate : Template
initialTemplate =
    {}
