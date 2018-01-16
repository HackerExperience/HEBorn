module Apps.Launch exposing (launch)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.Apps exposing (..)
import Apps.Messages exposing (..)
import Apps.Models exposing (..)
import Apps.Reference exposing (..)
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
import Apps.LogFlix.Models as LogFlix
import Apps.FloatingHeads.Models as FloatingHeads
import Apps.Popup.Models as Popup


--Remove on #367 PR

import Apps.Popup.Shared exposing (PopupType(..))


launch : Game.Data -> Reference -> App -> ( AppModel, Cmd Msg, Dispatch )
launch data ({ windowId } as reference) app =
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
            Browser.initialModel reference
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
            data
                |> ServersGears.initialModel
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

        BugApp ->
            Bug.initialModel
                |> BugModel
                |> Update.fromModel

        CalculatorApp ->
            Calculator.initialModel
                |> CalculatorModel
                |> Update.fromModel

        LogFlixApp ->
            LogFlix.initialModel
                |> LogFlixModel
                |> Update.fromModel

        FloatingHeadsApp ->
            FloatingHeads.initialModel reference
                |> FloatingHeadsModel
                |> Update.fromModel

        PopupApp ->
            Popup.initialModel ActivationPopup reference
                |> PopupModel
                |> Update.fromModel
