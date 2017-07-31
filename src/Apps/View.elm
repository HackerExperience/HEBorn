module Apps.View exposing (view)

import Html exposing (Html)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.View as LogViewer
import Apps.TaskManager.View as TaskManager
import Apps.Browser.View as Browser
import Apps.Explorer.View as Explorer
import Apps.DBAdmin.View as Database
import Apps.ConnManager.View as ConnManager
import Apps.BounceManager.View as BounceManager
import Apps.Finance.View as Finance
import Apps.Hebamp.View as Hebamp
import Apps.CtrlPanel.View as CtrlPanel
import Apps.ServersGears.View as ServersGears
import Apps.LocationPicker.View as LocationPicker
import Apps.LanViewer.View as LanViewer
import Game.Data as Game


view : Game.Data -> AppModel -> Html Msg
view data model =
    case model of
        LogViewerModel model ->
            Html.map LogViewerMsg (LogViewer.view data model)

        TaskManagerModel model ->
            Html.map TaskManagerMsg (TaskManager.view data model)

        BrowserModel model ->
            Html.map BrowserMsg (Browser.view data model)

        ExplorerModel model ->
            Html.map ExplorerMsg (Explorer.view data model)

        DatabaseModel model ->
            Html.map DatabaseMsg (Database.view data model)

        ConnManagerModel model ->
            Html.map ConnManagerMsg (ConnManager.view data model)

        BounceManagerModel model ->
            Html.map BounceManagerMsg (BounceManager.view data model)

        FinanceModel model ->
            Html.map FinanceMsg (Finance.view data model)

        MusicModel model ->
            Html.map MusicMsg (Hebamp.view data model)

        CtrlPanelModel model ->
            Html.map CtrlPanelMsg (CtrlPanel.view data model)

        ServersGearsModel model ->
            Html.map ServersGearsMsg (ServersGears.view data model)

        LocationPickerModel model ->
            Html.map LocationPickerMsg (LocationPicker.view data model)

        LanViewerModel model ->
            Html.map LanViewerMsg (LanViewer.view data model)
