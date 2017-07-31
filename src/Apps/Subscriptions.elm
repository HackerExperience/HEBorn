module Apps.Subscriptions exposing (subscriptions)

import Game.Data as Game
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


subscriptions : Game.Data -> AppModel -> Sub Msg
subscriptions data model =
    case model of
        LogViewerModel model ->
            LogViewer.subscriptions data model
                |> Sub.map LogViewerMsg

        TaskManagerModel model ->
            TaskManager.subscriptions data model
                |> Sub.map TaskManagerMsg

        BrowserModel model ->
            Browser.subscriptions data model
                |> Sub.map BrowserMsg

        ExplorerModel model ->
            Explorer.subscriptions data model
                |> Sub.map ExplorerMsg

        DatabaseModel model ->
            Database.subscriptions data model
                |> Sub.map DatabaseMsg

        ConnManagerModel model ->
            ConnManager.subscriptions data model
                |> Sub.map ConnManagerMsg

        BounceManagerModel model ->
            BounceManager.subscriptions data model
                |> Sub.map BounceManagerMsg

        FinanceModel model ->
            Finance.subscriptions data model
                |> Sub.map FinanceMsg

        MusicModel model ->
            Hebamp.subscriptions data model
                |> Sub.map MusicMsg

        CtrlPanelModel model ->
            CtrlPanel.subscriptions data model
                |> Sub.map CtrlPanelMsg

        ServersGearsModel model ->
            ServersGears.subscriptions data model
                |> Sub.map ServersGearsMsg

        LocationPickerModel model ->
            LocationPicker.subscriptions data model
                |> Sub.map LocationPickerMsg

        LanViewerModel model ->
            LanViewer.subscriptions data model
                |> Sub.map LanViewerMsg
