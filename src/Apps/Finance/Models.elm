module Apps.Finance.Models exposing (..)

import Apps.Finance.Menu.Models as Menu


type alias Model =
    { menu : Menu.Model
    , selected : MainTab
    }


type MainTab
    = TabMoney
    | TabBitcoin


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
    , selected = TabMoney
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabMoney ->
            "Money"

        TabBitcoin ->
            "BTC"
