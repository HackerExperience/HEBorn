module Apps.Finance.Models exposing (..)


type alias Model =
    { selected : MainTab
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
    { selected = TabMoney
    }


tabToString : MainTab -> String
tabToString tab =
    case tab of
        TabMoney ->
            "Money"

        TabBitcoin ->
            "BTC"
