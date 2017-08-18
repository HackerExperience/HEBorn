module Apps.Email.Models exposing (..)

import Apps.Email.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    }


name : String
name =
    "Thunderpigeon"


title : Model -> String
title model =
    "Thunderpigeon"


icon : String
icon =
    "email"


initialModel : Model
initialModel =
    { menu = Menu.initialMenu
    }
