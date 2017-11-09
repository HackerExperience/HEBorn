module Apps.Update exposing (update)

import Game.Data as Game
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
import Core.Dispatch as Dispatch exposing (Dispatch)


-- HACK : Elm's Tuple Pattern Matching is slow
-- https://groups.google.com/forum/#!topic/elm-dev/QGmwWH6V8-c


update :
    Game.Data
    -> Msg
    -> AppModel
    -> ( AppModel, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        LogViewerMsg msg ->
            case model of
                LogViewerModel model ->
                    map LogViewerModel
                        LogViewerMsg
                        (LogViewer.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        TaskManagerMsg msg ->
            case model of
                TaskManagerModel model ->
                    map TaskManagerModel
                        TaskManagerMsg
                        (TaskManager.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BrowserMsg msg ->
            case model of
                BrowserModel model ->
                    map BrowserModel
                        BrowserMsg
                        (Browser.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        ExplorerMsg msg ->
            case model of
                ExplorerModel model ->
                    map ExplorerModel
                        ExplorerMsg
                        (Explorer.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        DatabaseMsg msg ->
            case model of
                DatabaseModel model ->
                    map DatabaseModel
                        DatabaseMsg
                        (Database.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        ConnManagerMsg msg ->
            case model of
                ConnManagerModel model ->
                    map ConnManagerModel
                        ConnManagerMsg
                        (ConnManager.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BounceManagerMsg msg ->
            case model of
                BounceManagerModel model ->
                    map BounceManagerModel
                        BounceManagerMsg
                        (BounceManager.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        FinanceMsg msg ->
            case model of
                FinanceModel model ->
                    map FinanceModel
                        FinanceMsg
                        (Finance.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        MusicMsg msg ->
            case model of
                MusicModel model ->
                    map MusicModel MusicMsg (Hebamp.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        CtrlPanelMsg msg ->
            case model of
                CtrlPanelModel model ->
                    map CtrlPanelModel
                        CtrlPanelMsg
                        (CtrlPanel.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        ServersGearsMsg msg ->
            case model of
                ServersGearsModel model ->
                    map ServersGearsModel
                        ServersGearsMsg
                        (ServersGears.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        LocationPickerMsg msg ->
            case model of
                LocationPickerModel model ->
                    map LocationPickerModel
                        LocationPickerMsg
                        (LocationPicker.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        LanViewerMsg msg ->
            case model of
                LanViewerModel model ->
                    map LanViewerModel
                        LanViewerMsg
                        (LanViewer.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        EmailMsg msg ->
            case model of
                EmailModel model ->
                    map EmailModel EmailMsg (Email.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        BugMsg msg ->
            case model of
                BugModel model ->
                    map BugModel BugMsg (Bug.update data msg model)

                _ ->
                    ( model, Cmd.none, Dispatch.none )

        CalculatorMsg msg ->
            case model of
                CalculatorModel model ->
                    map CalculatorModel
                        CalculatorMsg
                        (Calculator.update data msg model)



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
--  _ ->
--      ( model, Cmd.none, Dispatch.none )


map :
    (model -> AppModel)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( AppModel, Cmd Msg, Dispatch )
map wrapModel wrapMsg ( model, cmd, dispatch ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, dispatch )
