module Apps.Launch exposing (launch)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.Apps exposing (..)
import Apps.Messages exposing (..)
import Apps.Models exposing (..)
import Apps.Config exposing (..)
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


launch : Game.Data -> Config -> App -> ( AppModel, Cmd Msg, Dispatch )
launch data ({ windowId } as config) app =
    case app of
        LogViewerApp ->
            LogViewer.initialModel
                |> LogViewerModel
                |> Update.fromModel

        TaskManagerApp ->
            TaskManager.initialModel
                |> TaskManagerModel
                |> Update.fromModel

        BrowserApp ->
            Browser.initialModel config
                |> BrowserModel
                |> Update.fromModel

        ExplorerApp ->
            Explorer.initialModel
                |> ExplorerModel
                |> Update.fromModel

        DatabaseApp ->
            Database.initialModel
                |> DatabaseModel
                |> Update.fromModel

        ConnManagerApp ->
            ConnManager.initialModel
                |> ConnManagerModel
                |> Update.fromModel

        BounceManagerApp ->
            BounceManager.initialModel
                |> BounceManagerModel
                |> Update.fromModel

        FinanceApp ->
            Finance.initialModel
                |> FinanceModel
                |> Update.fromModel

        MusicApp ->
            Hebamp.initialModel windowId
                |> MusicModel
                |> Update.fromModel

        CtrlPanelApp ->
            CtrlPanel.initialModel
                |> CtrlPanelModel
                |> Update.fromModel

        ServersGearsApp ->
            ServersGears.initialModel
                |> ServersGearsModel
                |> Update.fromModel

        LocationPickerApp ->
            let
                pureModel =
                    LocationPicker.initialModel windowId

                model =
                    LocationPickerModel pureModel

                cmd =
                    LocationPicker.startCmd pureModel
                        |> Cmd.map LocationPickerMsg
            in
                ( model, cmd, Dispatch.none )

        LanViewerApp ->
            LanViewer.initialModel
                |> LanViewerModel
                |> Update.fromModel

        EmailApp ->
            Email.initialModel
                |> EmailModel
                |> Update.fromModel
