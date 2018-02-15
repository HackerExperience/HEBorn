module Apps.Shared exposing (..)

import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Apps.LogViewer.Models as LogViewer
import Apps.TaskManager.Models as TaskManager
import Apps.Browser.Models as Browser
import Apps.Explorer.Models as Explorer
import Apps.DBAdmin.Models as Database
import Apps.ConnManager.Models as ConnManager
import Apps.BounceManager.Models as BounceManager
import Apps.Finance.Models as Finance
import Apps.Hebamp.Models as Hebamp
import Apps.CtrlPanel.Models as CtrlPanel
import Apps.ServersGears.Models as ServersGears
import Apps.LocationPicker.Models as LocationPicker
import Apps.LanViewer.Models as LanViewer
import Apps.Email.Models as Email
import Apps.Bug.Models as Bug
import Apps.Calculator.Models as Calculator
import Apps.BackFlix.Models as BackFlix
import Apps.FloatingHeads.Models as FloatingHeads


type AppContext
    = DynamicContext
    | StaticContext Context


context : DesktopApp -> AppContext
context app =
    case app of
        DesktopApp.LogViewer ->
            DynamicContext

        DesktopApp.TaskManager ->
            DynamicContext

        DesktopApp.Browser ->
            DynamicContext

        DesktopApp.Explorer ->
            DynamicContext

        DesktopApp.DBAdmin ->
            StaticContext Gateway

        DesktopApp.ConnManager ->
            StaticContext Gateway

        DesktopApp.BounceManager ->
            StaticContext Gateway

        DesktopApp.Finance ->
            StaticContext Gateway

        DesktopApp.Hebamp ->
            StaticContext Gateway

        DesktopApp.CtrlPanel ->
            StaticContext Gateway

        DesktopApp.ServersGears ->
            StaticContext Gateway

        DesktopApp.LocationPicker ->
            StaticContext Gateway

        DesktopApp.LanViewer ->
            DynamicContext

        DesktopApp.Email ->
            StaticContext Gateway

        DesktopApp.Bug ->
            DynamicContext

        DesktopApp.Calculator ->
            StaticContext Gateway

        DesktopApp.BackFlix ->
            StaticContext Gateway

        DesktopApp.FloatingHeads ->
            StaticContext Gateway


name : DesktopApp -> String
name app =
    case app of
        DesktopApp.LogViewer ->
            LogViewer.name

        DesktopApp.TaskManager ->
            TaskManager.name

        DesktopApp.Browser ->
            Browser.name

        DesktopApp.Explorer ->
            Explorer.name

        DesktopApp.DBAdmin ->
            Database.name

        DesktopApp.ConnManager ->
            ConnManager.name

        DesktopApp.BounceManager ->
            BounceManager.name

        DesktopApp.Finance ->
            Finance.name

        DesktopApp.Hebamp ->
            Hebamp.name

        DesktopApp.CtrlPanel ->
            CtrlPanel.name

        DesktopApp.ServersGears ->
            ServersGears.name

        DesktopApp.LocationPicker ->
            LocationPicker.name

        DesktopApp.LanViewer ->
            LanViewer.name

        DesktopApp.Email ->
            Email.name

        DesktopApp.Bug ->
            Bug.name

        DesktopApp.Calculator ->
            Calculator.name

        DesktopApp.BackFlix ->
            BackFlix.name

        DesktopApp.FloatingHeads ->
            FloatingHeads.name


icon : DesktopApp -> String
icon app =
    case app of
        DesktopApp.LogViewer ->
            LogViewer.icon

        DesktopApp.TaskManager ->
            TaskManager.icon

        DesktopApp.Browser ->
            Browser.icon

        DesktopApp.Explorer ->
            Explorer.icon

        DesktopApp.DBAdmin ->
            Database.icon

        DesktopApp.ConnManager ->
            ConnManager.icon

        DesktopApp.BounceManager ->
            BounceManager.icon

        DesktopApp.Finance ->
            Finance.icon

        DesktopApp.Hebamp ->
            Hebamp.icon

        DesktopApp.CtrlPanel ->
            CtrlPanel.icon

        DesktopApp.ServersGears ->
            ServersGears.icon

        DesktopApp.LocationPicker ->
            LocationPicker.icon

        DesktopApp.LanViewer ->
            LanViewer.icon

        DesktopApp.Email ->
            Email.icon

        DesktopApp.Bug ->
            Bug.icon

        DesktopApp.Calculator ->
            Calculator.icon

        DesktopApp.BackFlix ->
            BackFlix.icon

        DesktopApp.FloatingHeads ->
            FloatingHeads.icon


windowInitSize : DesktopApp -> ( Float, Float )
windowInitSize app =
    case app of
        DesktopApp.Email ->
            Email.windowInitSize

        DesktopApp.Browser ->
            Browser.windowInitSize

        DesktopApp.Calculator ->
            Calculator.windowInitSize

        DesktopApp.BackFlix ->
            BackFlix.windowInitSize

        _ ->
            ( 600, 400 )
