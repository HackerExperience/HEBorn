module OS.WindowManager.Messages exposing (..)

import Draggable
import Game.Meta.Types.Context exposing (..)
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Servers.Shared exposing (CId)
import Apps.Params as AppParams exposing (AppParams)
import Apps.LogViewer.Messages as LogViewer
import Apps.TaskManager.Messages as TaskManager
import Apps.Browser.Messages as Browser
import Apps.Explorer.Messages as Explorer
import Apps.DBAdmin.Messages as DBAdmin
import Apps.ConnManager.Messages as ConnManager
import Apps.BounceManager.Messages as BounceManager
import Apps.Finance.Messages as Finance
import Apps.Hebamp.Messages as Hebamp
import Apps.ServersGears.Messages as ServersGears
import Apps.LocationPicker.Messages as LocationPicker
import Apps.Email.Messages as Email
import Apps.Bug.Messages as Bug
import Apps.Calculator.Messages as Calculator
import Apps.BackFlix.Messages as BackFlix
import Apps.FloatingHeads.Messages as FloatingHeads
import OS.WindowManager.Shared exposing (..)


type Msg
    = NewApp DesktopApp (Maybe Context) (Maybe AppParams)
    | OpenApp CId AppParams
    | LazyLaunchEndpoint WindowId DesktopApp
      -- window handling
    | Close WindowId
    | Minimize WindowId
    | ToggleVisibility WindowId
    | ToggleMaximize WindowId
    | ToggleContext WindowId
    | SelectContext Context WindowId
    | UpdateFocus (Maybe WindowId)
    | Pin WindowId
    | Unpin WindowId
      -- drag messages
    | StartDrag WindowId
    | Dragging Draggable.Delta
    | StopDrag
    | DragMsg (Draggable.Msg WindowId)
      -- dock messages
    | ClickIcon DesktopApp
    | MinimizeAll DesktopApp
    | CloseAll DesktopApp
      -- app messages
    | AppMsg AppId AppMsg
    | AppsMsg AppMsg


type AppMsg
    = BackFlixMsg BackFlix.Msg
    | BounceManagerMsg BounceManager.Msg
    | BrowserMsg Browser.Msg
    | BugMsg Bug.Msg
    | CalculatorMsg Calculator.Msg
    | ConnManagerMsg ConnManager.Msg
    | DBAdminMsg DBAdmin.Msg
    | EmailMsg Email.Msg
    | ExplorerMsg Explorer.Msg
    | FinanceMsg Finance.Msg
    | FloatingHeadsMsg FloatingHeads.Msg
    | HebampMsg Hebamp.Msg
    | LocationPickerMsg LocationPicker.Msg
    | LogViewerMsg LogViewer.Msg
    | ServersGearsMsg ServersGears.Msg
    | TaskManagerMsg TaskManager.Msg


msgToDesktopApp : AppMsg -> DesktopApp
msgToDesktopApp desktopMsg =
    case desktopMsg of
        BackFlixMsg _ ->
            DesktopApp.BackFlix

        BounceManagerMsg _ ->
            DesktopApp.BounceManager

        BrowserMsg _ ->
            DesktopApp.Browser

        BugMsg _ ->
            DesktopApp.Bug

        CalculatorMsg _ ->
            DesktopApp.Calculator

        ConnManagerMsg _ ->
            DesktopApp.ConnManager

        DBAdminMsg _ ->
            DesktopApp.DBAdmin

        EmailMsg _ ->
            DesktopApp.Email

        ExplorerMsg _ ->
            DesktopApp.Explorer

        FinanceMsg _ ->
            DesktopApp.Finance

        FloatingHeadsMsg _ ->
            DesktopApp.FloatingHeads

        HebampMsg _ ->
            DesktopApp.Hebamp

        LocationPickerMsg _ ->
            DesktopApp.LocationPicker

        LogViewerMsg _ ->
            DesktopApp.LogViewer

        ServersGearsMsg _ ->
            DesktopApp.ServersGears

        TaskManagerMsg _ ->
            DesktopApp.TaskManager
