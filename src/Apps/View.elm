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
import Game.Data as Game


view : Config msg -> Game.Data -> AppModel -> Html msg
view config data model =
    case model of
        LogViewerModel model ->
            let
                config_ =
                    logViewerConfig config
            in
                LogViewer.view config_ model

        TaskManagerModel model ->
            let
                config_ =
                    taskManConfig config
            in
                TaskManager.view config_ model

        BrowserModel model ->
            Html.map (BrowserMsg >> config.toMsg) (Browser.view data model)

        ExplorerModel model ->
            let
                config_ =
                    explorerConfig config
            in
                Explorer.view config_ model

        DatabaseModel model ->
            Html.map (DatabaseMsg >> config.toMsg) (Database.view data model)

        ConnManagerModel model ->
            Html.map (ConnManagerMsg >> config.toMsg) (ConnManager.view data model)

        BounceManagerModel model ->
            Html.map (BounceManagerMsg >> config.toMsg) (BounceManager.view data model)

        FinanceModel model ->
            Html.map (FinanceMsg >> config.toMsg) (Finance.view data model)

        MusicModel model ->
            Html.map (MusicMsg >> config.toMsg) (Hebamp.view data model)

        CtrlPanelModel model ->
            let
                config_ =
                    ctrlPainelConfig config
            in
                CtrlPanel.view config_ model

        ServersGearsModel model ->
            Html.map (ServersGearsMsg >> config.toMsg) (ServersGears.view data model)

        LocationPickerModel model ->
            Html.map (LocationPickerMsg >> config.toMsg) (LocationPicker.view data model)

        LanViewerModel model ->
            let
                config_ =
                    lanViewerConfig config
            in
                LanViewer.view config_ model

        EmailModel model ->
            Html.map (EmailMsg >> config.toMsg) (Email.view data model)

        BugModel model ->
            Html.map (BugMsg >> config.toMsg) (Bug.view data model)

        CalculatorModel model ->
            let
                config_ =
                    calculatorConfig config
            in
                Calculator.view config_ model

        BackFlixModel model ->
            Html.map (BackFlixMsg >> config.toMsg) (BackFlix.view data model)

        FloatingHeadsModel model ->
            Html.map (FloatingHeadsMsg >> config.toMsg) (FloatingHeads.view data model)


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
