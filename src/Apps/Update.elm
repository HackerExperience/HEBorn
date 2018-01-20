module Apps.Update exposing (update)

import Utils.Update as Update
import Game.Data as Game
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
import Apps.CtrlPanel.Update as CtrlPanel
import Apps.ServersGears.Update as ServersGears
import Apps.LocationPicker.Update as LocationPicker
import Apps.LanViewer.Update as LanViewer
import Apps.Email.Update as Email
import Apps.Bug.Update as Bug
import Apps.Calculator.Update as Calculator
import Apps.BackFlix.Update as BackFlix
import Apps.FloatingHeads.Update as FloatingHeads
import Core.Dispatch as Dispatch exposing (Dispatch)


-- HACK : Elm's Tuple Pattern Matching is slow
-- https://groups.google.com/forum/#!topic/elm-dev/QGmwWH6V8-c
--------------------------------------------------------------
-- CONFREFACT: remove Game.Data after refactor


update :
    Config msg
    -> Game.Data
    -> Msg
    -> AppModel
    -> ( AppModel, Cmd msg, Dispatch )
update config data msg model =
    case msg of
        LogViewerMsg msg ->
            case model of
                LogViewerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            LogViewer.update data msg model

                        cmd_ =
                            Update.mapCmd (LogViewerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config LogViewerModel LogViewerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        TaskManagerMsg msg ->
            case model of
                TaskManagerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            TaskManager.update data msg model

                        cmd_ =
                            Update.mapCmd (TaskManagerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config TaskManagerModel TaskManagerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BrowserMsg msg ->
            case model of
                BrowserModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Browser.update data msg model

                        cmd_ =
                            Update.mapCmd (BrowserMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config BrowserModel BrowserMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        ExplorerMsg msg ->
            case model of
                ExplorerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Explorer.update data msg model

                        cmd_ =
                            Update.mapCmd (ExplorerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config ExplorerModel ExplorerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        DatabaseMsg msg ->
            case model of
                DatabaseModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Database.update data msg model

                        cmd_ =
                            Update.mapCmd (DatabaseMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config DatabaseModel DatabaseMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        ConnManagerMsg msg ->
            case model of
                ConnManagerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            ConnManager.update data msg model

                        cmd_ =
                            Update.mapCmd (ConnManagerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config ConnManagerModel ConnManagerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BounceManagerMsg msg ->
            case model of
                BounceManagerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            BounceManager.update data msg model

                        cmd_ =
                            Update.mapCmd (BounceManagerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config BounceManagerModel BounceManagerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        FinanceMsg msg ->
            case model of
                FinanceModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Finance.update data msg model

                        cmd_ =
                            Update.mapCmd (FinanceMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config FinanceModel FinanceMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        MusicMsg msg ->
            case model of
                MusicModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Hebamp.update data msg model

                        cmd_ =
                            Update.mapCmd (MusicMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config MusicModel MusicMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        CtrlPanelMsg msg ->
            case model of
                CtrlPanelModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            CtrlPanel.update data msg model

                        cmd_ =
                            Update.mapCmd (CtrlPanelMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config CtrlPanelModel CtrlPanelMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        ServersGearsMsg msg ->
            case model of
                ServersGearsModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            ServersGears.update data msg model

                        cmd_ =
                            Update.mapCmd (ServersGearsMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config ServersGearsModel ServersGearsMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        LocationPickerMsg msg ->
            case model of
                LocationPickerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            LocationPicker.update data msg model

                        cmd_ =
                            Update.mapCmd (LocationPickerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config LocationPickerModel LocationPickerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        LanViewerMsg msg ->
            case model of
                LanViewerModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            LanViewer.update data msg model

                        cmd_ =
                            Update.mapCmd (LanViewerMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config LanViewerModel LanViewerMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        EmailMsg msg ->
            case model of
                EmailModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Email.update data msg model

                        cmd_ =
                            Update.mapCmd (EmailMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config EmailModel EmailMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BugMsg msg ->
            case model of
                BugModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            Bug.update data msg model

                        cmd_ =
                            Update.mapCmd (BugMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config BugModel BugMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        CalculatorMsg msg ->
            case model of
                CalculatorModel model ->
                    let
                        config_ =
                            calculatorConfig config

                        update_ =
                            (Calculator.update config_ msg model)
                    in
                        map config CalculatorModel CalculatorMsg update_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BackFlixMsg msg ->
            case model of
                BackFlixModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            BackFlix.update data msg model

                        cmd_ =
                            Update.mapCmd (BackFlixMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config BackFlixModel BackFlixMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        FloatingHeadsMsg msg ->
            case model of
                FloatingHeadsModel model ->
                    let
                        ( model_, cmd, dispatch ) =
                            FloatingHeads.update data msg model

                        cmd_ =
                            Update.mapCmd (FloatingHeadsMsg >> config.toMsg) ( model_, cmd, dispatch )
                    in
                        map config FloatingHeadsModel FloatingHeadsMsg cmd_

                _ ->
                    ( model, Cmd.none, Dispatch.none )



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
    Config msg
    -> (model -> AppModel)
    -> (appMsg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( AppModel, Cmd msg, Dispatch )
map config wrapModel wrapMsg ( model, cmd, dispatch ) =
    let
        update_ =
            ( wrapModel model, cmd, dispatch )
    in
        update_
