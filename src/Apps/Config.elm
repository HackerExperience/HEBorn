module Apps.Config exposing (..)

import Apps.Messages exposing (..)
import Apps.CtrlPanel.Config as CtrlPanel
import Apps.LanViewer.Config as LanViewer
import Apps.Calculator.Config as Calculator


type alias Config msg =
    { toMsg : Msg -> msg
    }


calculatorConfig : Config msg -> Calculator.Config msg
calculatorConfig config =
    { toMsg = CalculatorMsg >> config.toMsg }


ctrlPainelConfig : Config msg -> CtrlPanel.Config
ctrlPainelConfig config =
    {}


lanViewerConfig : Config msg -> LanViewer.Config
lanViewerConfig config =
    {}
