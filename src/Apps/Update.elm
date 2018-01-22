module Apps.Update exposing (update)

import Utils.React as React exposing (React)
import Apps.Config exposing (..)
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Update as LogViewer
import Apps.TaskManager.Update as TaskManager
import Apps.Browser.Update as Browser
import Apps.Explorer.Update as Explorer
import Apps.DBAdmin.Update as Database
import Apps.ConnManager.Update as ConnManager
import Apps.BounceManager.Update as BounceManager
import Apps.Finance.Update as Finance
import Apps.Hebamp.Update as Hebamp
import Apps.ServersGears.Update as ServersGears
import Apps.LocationPicker.Update as LocationPicker
import Apps.Email.Update as Email
import Apps.Bug.Update as Bug
import Apps.Calculator.Update as Calculator
import Apps.BackFlix.Update as BackFlix
import Apps.FloatingHeads.Update as FloatingHeads


-- HACK : Elm's Tuple Pattern Matching is slow
-- https://groups.google.com/forum/#!topic/elm-dev/QGmwWH6V8-c
--------------------------------------------------------------


update :
    Config msg
    -> Msg
    -> AppModel
    -> ( AppModel, React msg )
update config msg model =
    case msg of
        LogViewerMsg msg ->
            case model of
                LogViewerModel model ->
                    let
                        config_ =
                            logViewerConfig config

                        update_ =
                            LogViewer.update config_ msg model
                    in
                        map LogViewerModel LogViewerMsg update_

                _ ->
                    ( model, React.none )

        TaskManagerMsg msg ->
            case model of
                TaskManagerModel model ->
                    let
                        config_ =
                            taskManConfig config

                        update_ =
                            TaskManager.update config_ msg model
                    in
                        map TaskManagerModel TaskManagerMsg update_

                _ ->
                    ( model, React.none )

        BrowserMsg msg ->
            case model of
                BrowserModel model ->
                    let
                        config_ =
                            browserConfig config

                        cmd_ =
                            Browser.update config_ msg model
                    in
                        map BrowserModel BrowserMsg cmd_

                _ ->
                    ( model, React.none )

        ExplorerMsg msg ->
            case model of
                ExplorerModel model ->
                    let
                        config_ =
                            explorerConfig config

                        update_ =
                            Explorer.update config_ msg model
                    in
                        map ExplorerModel ExplorerMsg update_

                _ ->
                    ( model, React.none )

        DatabaseMsg msg ->
            case model of
                DatabaseModel model ->
                    let
                        config_ =
                            dbAdminConfig config

                        update_ =
                            Database.update config_ msg model
                    in
                        map DatabaseModel DatabaseMsg update_

                _ ->
                    ( model, React.none )

        ConnManagerMsg msg ->
            case model of
                ConnManagerModel model ->
                    let
                        config_ =
                            connManagerConfig config

                        update_ =
                            ConnManager.update config_ msg model
                    in
                        map ConnManagerModel ConnManagerMsg update_

                _ ->
                    ( model, React.none )

        BounceManagerMsg msg ->
            case model of
                BounceManagerModel model ->
                    let
                        config_ =
                            bounceManConfig config

                        update_ =
                            BounceManager.update config_ msg model
                    in
                        map BounceManagerModel BounceManagerMsg update_

                _ ->
                    ( model, React.none )

        FinanceMsg msg ->
            case model of
                FinanceModel model ->
                    let
                        config_ =
                            financeConfig config

                        update_ =
                            Finance.update config_ msg model
                    in
                        map FinanceModel FinanceMsg update_

                _ ->
                    ( model, React.none )

        MusicMsg msg ->
            case model of
                MusicModel model ->
                    let
                        config_ =
                            hebampConfig config

                        update_ =
                            Hebamp.update config_ msg model
                    in
                        map MusicModel MusicMsg update_

                _ ->
                    ( model, React.none )

        ServersGearsMsg msg ->
            case model of
                ServersGearsModel model ->
                    let
                        config_ =
                            serversGearsConfig config

                        update_ =
                            ServersGears.update config_ msg model
                    in
                        map ServersGearsModel ServersGearsMsg update_

                _ ->
                    ( model, React.none )

        LocationPickerMsg msg ->
            case model of
                LocationPickerModel model ->
                    let
                        config_ =
                            locationPickerConfig config

                        update_ =
                            LocationPicker.update config_ msg model
                    in
                        map LocationPickerModel LocationPickerMsg update_

                _ ->
                    ( model, React.none )

        EmailMsg msg ->
            case model of
                EmailModel model ->
                    let
                        config_ =
                            emailConfig config

                        update_ =
                            Email.update config_ msg model
                    in
                        map EmailModel EmailMsg update_

                _ ->
                    ( model, React.none )

        BugMsg msg ->
            case model of
                BugModel model ->
                    let
                        config_ =
                            bugConfig config

                        update_ =
                            Bug.update config_ msg model
                    in
                        map BugModel BugMsg update_

                _ ->
                    ( model, React.none )

        CalculatorMsg msg ->
            case model of
                CalculatorModel model ->
                    let
                        config_ =
                            calculatorConfig config

                        update_ =
                            (Calculator.update config_ msg model)
                    in
                        map CalculatorModel CalculatorMsg update_

                _ ->
                    ( model, React.none )

        BackFlixMsg msg ->
            case model of
                BackFlixModel model ->
                    let
                        config_ =
                            backFlixConfig config

                        update_ =
                            BackFlix.update config_ msg model
                    in
                        map BackFlixModel BackFlixMsg update_

                _ ->
                    ( model, React.none )

        FloatingHeadsMsg msg ->
            case model of
                FloatingHeadsModel model ->
                    let
                        config_ =
                            floatingHeadsConfig config

                        update_ =
                            FloatingHeads.update config_ msg model
                    in
                        map FloatingHeadsModel FloatingHeadsMsg update_

                _ ->
                    ( model, React.none )



--case ( msg, model ) of
--  ( LogViewerMsg msg, LogViewerModel model ) ->
--      map LogViewerModel LogViewerMsg (LogViewer.update data msg model)
--  ( TaskManagerMsg msg, TaskManagerModel model ) ->
--      map TaskManagerModel TaskManagerMsg (TaskManager.update data msg model)
--  ( BrowserMsg msg, BrowserModel model ) ->
--      map BrowserModel BrowserMsg (Browser.update data msg model)
--  ( ExplorerMsg msg, ExplorerModel model ) ->
--      map ExplorerModel ExplorerMsg (Explorer.update data msg model)
--  ( DatabaseMsg msg, DatabaseModel model ) ->
--      map DatabaseModel DatabaseMsg (Database.update data msg model)
--  ( ConnManagerMsg msg, ConnManagerModel model ) ->
--      map ConnManagerModel ConnManagerMsg (ConnManager.update data msg model)
--  ( BounceManagerMsg msg, BounceManagerModel model ) ->
--      map BounceManagerModel BounceManagerMsg (BounceManager.update data msg model)
--  ( FinanceMsg msg, FinanceModel model ) ->
--      map FinanceModel FinanceMsg (Finance.update data msg model)
--  ( MusicMsg msg, MusicModel model ) ->
--      map MusicModel MusicMsg (Hebamp.update data msg model)
--  ( CtrlPanelMsg msg, CtrlPanelModel model ) ->
--      map CtrlPanelModel CtrlPanelMsg (CtrlPanel.update data msg model)
--  ( ServersGearsMsg msg, ServersGearsModel model ) ->
--      map ServersGearsModel ServersGearsMsg (ServersGears.update data msg model)
--  ( LocationPickerMsg msg, LocationPickerModel model ) ->
--      map LocationPickerModel LocationPickerMsg (LocationPicker.update data msg model)
--  ( LanViewerMsg msg, LanViewerModel model ) ->
--      map LanViewerModel LanViewerMsg (LanViewer.update data msg model)
--  ( EmailMsg msg, EmailModel model ) ->
--      map EmailModel EmailMsg (Email.update data msg model)
--  ( BugMsg msg, BugModel model ) ->
--      map BugModel BugMsg (Bug.update data msg model)
--  ( CalculatorMsg msg, CalculatorModel model ) ->
--      map CalculatorModel CalculatorMsg (Calculator.update data msg model)
--  ( FloatingHeadsMsg msg, FloatingHeadsModel model ) ->
--      map FloatingHeadsModel FloatingHeadsMsg (FloatingHeads.update data msg model)
--  _ ->
--      ( model, Cmd.none, Dispatch.none )


map :
    (model -> AppModel)
    -> (appMsg -> Msg)
    -> ( model, React msg )
    -> ( AppModel, React msg )
map wrapModel wrapMsg ( model, react ) =
    let
        update_ =
            ( wrapModel model, react )
    in
        update_
