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
import Apps.FloatingHeads.Messages as FloatingHeadsMessages


view : Config msg -> AppModel -> Html msg
view config model =
    case model of
        LogViewerModel model ->
            let
                config_ =
                    logViewerConfig config
            in
                Html.map (LogViewerMsg >> config.toMsg) (LogViewer.view config_ model)

        TaskManagerModel model ->
            let
                config_ =
                    taskManConfig config
            in
                Html.map (TaskManagerMsg >> config.toMsg) (TaskManager.view config_ model)

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
            let
                config_ =
                    financeConfig config
            in
                Html.map (FinanceMsg >> config.toMsg) (Finance.view config_ model)

        MusicModel model ->
            let
                config_ =
                    hebampConfig config
            in
                Html.map (MusicMsg >> config.toMsg) (Hebamp.view config_ model)

        CtrlPanelModel model ->
            let
                config_ =
                    ctrlPainelConfig config
            in
                CtrlPanel.view config_ model

        ServersGearsModel model ->
            let
                config_ =
                    serversGearsConfig config
            in
                Html.map (ServersGearsMsg >> config.toMsg) (ServersGears.view config_ model)

        LocationPickerModel model ->
            let
                config_ =
                    locationPickerConfig config
            in
                Html.map (LocationPickerMsg >> config.toMsg) (LocationPicker.view config_ model)

        LanViewerModel model ->
            let
                config_ =
                    lanViewerConfig config
            in
                LanViewer.view config_ model

        EmailModel model ->
            let
                config_ =
                    emailConfig config
            in
                Html.map (EmailMsg >> config.toMsg) (Email.view config_ model)

        BugModel model ->
            Bug.view (bugConfig config) model

        CalculatorModel model ->
            Calculator.view (calculatorConfig config) model

        BackFlixModel model ->
            BackFlix.view (backFlixConfig config) model

        FloatingHeadsModel model ->
            let
                config_ =
                    floatingHeadsConfig config
            in
                (FloatingHeads.view config_ model)
                    |> Html.map (FloatingHeadsMsg >> config.toMsg)


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
