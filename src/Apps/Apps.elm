module Apps.Apps exposing (App(..), AppParams(..), paramsToApp)

import Apps.Browser.Models as Browser
import Apps.FloatingHeads.Models as FloatingHeads
import Apps.Hebamp.Shared as Hebamp


type App
    = LogViewerApp
    | TaskManagerApp
    | BrowserApp
    | ExplorerApp
    | DatabaseApp
    | ConnManagerApp
    | BounceManagerApp
    | FinanceApp
    | MusicApp
    | CtrlPanelApp
    | ServersGearsApp
    | LocationPickerApp
    | LanViewerApp
    | EmailApp
    | BugApp
    | CalculatorApp
    | BackFlixApp
    | FloatingHeadsApp


type AppParams
    = BrowserParams Browser.Params
    | FloatingHeadsParams FloatingHeads.Params
    | MusicParams Hebamp.Params


paramsToApp : AppParams -> App
paramsToApp params =
    case params of
        BrowserParams _ ->
            BrowserApp

        FloatingHeadsParams _ ->
            FloatingHeadsApp

        MusicParams _ ->
            MusicApp
