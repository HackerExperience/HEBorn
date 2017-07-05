module Apps.Finance.Models exposing (..)

import Apps.Finance.Menu.Models as Menu


type alias Finance =
    {}


type alias Model =
    { app : Finance
    , menu : Menu.Model
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
    { app = initialFinance
    , menu = Menu.initialMenu
    }


initialFinance : Finance
initialFinance =
    {}
