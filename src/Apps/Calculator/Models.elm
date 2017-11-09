module Apps.Calculator.Models exposing (..)

import Apps.Calculator.Menu.Models as Menu


type Operator
    = Typing String
    | Add String Operator
    | Sub String Operator
    | Div String Operator
    | Mul String Operator
    | Pow String Operator
    | IsNotANumber
    | DivideBy0
    | InvalidOperation
    | None


type alias Model =
    { display : Operator
    , menu : Menu.Model
    }


name : String
name =
    "Calculator"


title : Model -> String
title model =
    "Calculator"


icon : String
icon =
    "calculator"


initialModel : Model
initialModel =
    { display = Typing "0"
    , menu = Menu.initialMenu
    }
