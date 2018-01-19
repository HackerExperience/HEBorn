module Apps.Config exposing (..)

import Apps.Messages exposing (..)
import Apps.Calculator.Config as Calculator


type alias Config msg =
    { toMsg : Msg -> msg
    }


calculatorConfig : Config msg -> Calculator.Config msg
calculatorConfig config =
    { toMsg = CalculatorMsg >> config.toMsg }
