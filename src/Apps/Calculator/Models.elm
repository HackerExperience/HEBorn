module Apps.Calculator.Models exposing (..)


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
    }


name : String
name =
    "Calculator"


title : Model -> String
title model =
    "Calculator"


windowInitSize : ( Int, Int )
windowInitSize =
    ( 195, 243 )


icon : String
icon =
    "calculator"


initialModel : Model
initialModel =
    { display = Typing "0"
    }
