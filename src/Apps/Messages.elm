module Apps.Messages exposing (Msg(..))

import Apps.LogViewer.Messages as LogViewer
import Apps.TaskManager.Messages as TaskManager
import Apps.Browser.Messages as Browser
import Apps.Explorer.Messages as Explorer
import Apps.DBAdmin.Messages as Database
import Apps.ConnManager.Messages as ConnManager
import Apps.BounceManager.Messages as BounceManager
import Apps.Finance.Messages as Finance
import Apps.Hebamp.Messages as Hebamp
import Apps.CtrlPanel.Messages as CtrlPanel
import Apps.ServersGears.Messages as ServersGears
import Apps.LocationPicker.Messages as LocationPicker
import Apps.LanViewer.Messages as LanViewer
import Apps.Email.Messages as Email
import Apps.Bug.Messages as Bug
import Apps.Calculator.Messages as Calculator
import Apps.LogFlix.Messages as LogFlix
import Apps.FloatingHeads.Messages as FloatingHeads


type Msg
    = LogViewerMsg LogViewer.Msg
    | TaskManagerMsg TaskManager.Msg
    | BrowserMsg Browser.Msg
    | ExplorerMsg Explorer.Msg
    | DatabaseMsg Database.Msg
    | ConnManagerMsg ConnManager.Msg
    | BounceManagerMsg BounceManager.Msg
    | FinanceMsg Finance.Msg
    | MusicMsg Hebamp.Msg
    | CtrlPanelMsg CtrlPanel.Msg
    | ServersGearsMsg ServersGears.Msg
    | LocationPickerMsg LocationPicker.Msg
    | LanViewerMsg LanViewer.Msg
    | EmailMsg Email.Msg
    | BugMsg Bug.Msg
    | CalculatorMsg Calculator.Msg
    | LogFlixMsg LogFlix.Msg
    | FloatingHeadsMsg FloatingHeads.Msg
