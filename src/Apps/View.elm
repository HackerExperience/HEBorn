module Apps.View
    exposing
        ( view
        , isDecorated
        , isResizable
        , keyLogger
        )

import Html exposing (Html)
import Apps.Apps exposing (..)
import Apps.Config exposing (..)
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
import Apps.Email.View as Email
import Apps.Bug.View as Bug
import Apps.Calculator.View as Calculator
import Apps.Calculator.Messages as CalculatorMessages
import Apps.BackFlix.View as BackFlix
import Apps.FloatingHeads.View as FloatingHeads


view : Config msg -> AppModel -> Html msg
view config model =
    case model of
        LogViewerModel model ->
            LogViewer.view (logViewerConfig config) model

        TaskManagerModel model ->
            TaskManager.view (taskManConfig config) model

        BrowserModel model ->
            Browser.view (browserConfig config) model

        ExplorerModel model ->
            Explorer.view (explorerConfig config) model

        DatabaseModel model ->
            Database.view (dbAdminConfig config) model

        ConnManagerModel model ->
            ConnManager.view (connManagerConfig config) model

        BounceManagerModel model ->
            BounceManager.view (bounceManConfig config) model

        FinanceModel model ->
            Finance.view (financeConfig config) model

        MusicModel model ->
            Hebamp.view (hebampConfig config) model

        CtrlPanelModel model ->
            CtrlPanel.view (ctrlPainelConfig config) model

        ServersGearsModel model ->
            ServersGears.view (serversGearsConfig config) model

        LocationPickerModel model ->
            LocationPicker.view (locationPickerConfig config) model

        LanViewerModel model ->
            LanViewer.view (lanViewerConfig config) model

        EmailModel model ->
            Email.view (emailConfig config) model

        BugModel model ->
            Bug.view (bugConfig config) model

        CalculatorModel model ->
            Calculator.view (calculatorConfig config) model

        BackFlixModel model ->
            BackFlix.view (backFlixConfig config) model

        FloatingHeadsModel model ->
            FloatingHeads.view (floatingHeadsConfig config) model


isDecorated : App -> Bool
isDecorated app =
    case app of
        MusicApp ->
            False

        FloatingHeadsApp ->
            False

        _ ->
            True


isResizable : App -> Bool
isResizable app =
    case app of
        EmailApp ->
            False

        _ ->
            True


keyLogger : App -> Maybe (Int -> Msg)
keyLogger app =
    case app of
        CalculatorApp ->
            CalculatorMessages.KeyMsg >> CalculatorMsg |> Just

        _ ->
            Nothing
