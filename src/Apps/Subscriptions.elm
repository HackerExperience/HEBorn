module Apps.Subscriptions exposing (subscriptions)

import Game.Data as Game
import Apps.Config exposing (..)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Subscriptions as LogViewer
import Apps.TaskManager.Subscriptions as TaskManager
import Apps.Browser.Subscriptions as Browser
import Apps.Explorer.Subscriptions as Explorer
import Apps.DBAdmin.Subscriptions as Database
import Apps.ConnManager.Subscriptions as ConnManager
import Apps.BounceManager.Subscriptions as BounceManager
import Apps.Finance.Subscriptions as Finance
import Apps.Hebamp.Subscriptions as Hebamp
import Apps.CtrlPanel.Subscriptions as CtrlPanel
import Apps.ServersGears.Subscriptions as ServersGears
import Apps.LocationPicker.Subscriptions as LocationPicker
import Apps.LanViewer.Subscriptions as LanViewer
import Apps.Email.Subscriptions as Email
import Apps.Bug.Subscriptions as Bug
import Apps.Calculator.Subscriptions as Calculator
import Apps.BackFlix.Subscriptions as BackFlix
import Apps.FloatingHeads.Subscriptions as FloatingHeads


subscriptions : Config msg -> Game.Data -> AppModel -> Sub msg
subscriptions config data model =
    case model of
        LogViewerModel model ->
            LogViewer.subscriptions data model
                |> Sub.map (LogViewerMsg >> config.toMsg)

        TaskManagerModel model ->
            TaskManager.subscriptions data model
                |> Sub.map (TaskManagerMsg >> config.toMsg)

        BrowserModel model ->
            Browser.subscriptions data model
                |> Sub.map (BrowserMsg >> config.toMsg)

        ExplorerModel model ->
            Explorer.subscriptions data model
                |> Sub.map (ExplorerMsg >> config.toMsg)

        DatabaseModel model ->
            Database.subscriptions data model
                |> Sub.map (DatabaseMsg >> config.toMsg)

        ConnManagerModel model ->
            ConnManager.subscriptions data model
                |> Sub.map (ConnManagerMsg >> config.toMsg)

        BounceManagerModel model ->
            BounceManager.subscriptions data model
                |> Sub.map (BounceManagerMsg >> config.toMsg)

        FinanceModel model ->
            Finance.subscriptions data model
                |> Sub.map (FinanceMsg >> config.toMsg)

        MusicModel model ->
            Hebamp.subscriptions data model
                |> Sub.map (MusicMsg >> config.toMsg)

        CtrlPanelModel model ->
            CtrlPanel.subscriptions data model
                |> Sub.map (CtrlPanelMsg >> config.toMsg)

        ServersGearsModel model ->
            ServersGears.subscriptions data model
                |> Sub.map (ServersGearsMsg >> config.toMsg)

        LocationPickerModel model ->
            LocationPicker.subscriptions data model
                |> Sub.map (LocationPickerMsg >> config.toMsg)

        LanViewerModel model ->
            LanViewer.subscriptions data model
                |> Sub.map (LanViewerMsg >> config.toMsg)

        EmailModel model ->
            Email.subscriptions data model
                |> Sub.map (EmailMsg >> config.toMsg)

        BugModel model ->
            Bug.subscriptions data model
                |> Sub.map (BugMsg >> config.toMsg)

        BackFlixModel model ->
            BackFlix.subscriptions data model
                |> Sub.map (BackFlixMsg >> config.toMsg)

        FloatingHeadsModel model ->
            FloatingHeads.subscriptions data model
                |> Sub.map (FloatingHeadsMsg >> config.toMsg)

        _ ->
            Sub.none
