module Apps.Email.Models exposing (..)

import Apps.Email.Menu.Models as Menu


type alias Email =
    {}


type alias Model =
    { app : Email
    , menu : Menu.Model
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
    { app = initialEmail
    , menu = Menu.initialMenu
    }


initialEmail : Email
initialEmail =
    {}
