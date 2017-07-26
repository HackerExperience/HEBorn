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
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Data
    -> Msg
    -> AppModel
    -> ( AppModel, Cmd Msg, Dispatch )
update data msg model =
    case ( msg, model ) of
        ( Loaded wId, _ ) ->
            appLoaded wId data model

        ( LogViewerMsg msg, LogViewerModel model ) ->
            map LogViewerModel LogViewerMsg (LogViewer.update data msg model)

        ( TaskManagerMsg msg, TaskManagerModel model ) ->
            map TaskManagerModel TaskManagerMsg (TaskManager.update data msg model)

        ( BrowserMsg msg, BrowserModel model ) ->
            map BrowserModel BrowserMsg (Browser.update data msg model)

        ( ExplorerMsg msg, ExplorerModel model ) ->
            map ExplorerModel ExplorerMsg (Explorer.update data msg model)

        ( DatabaseMsg msg, DatabaseModel model ) ->
            map DatabaseModel DatabaseMsg (Database.update data msg model)

        ( ConnManagerMsg msg, ConnManagerModel model ) ->
            map ConnManagerModel ConnManagerMsg (ConnManager.update data msg model)

        ( BounceManagerMsg msg, BounceManagerModel model ) ->
            map BounceManagerModel BounceManagerMsg (BounceManager.update data msg model)

        ( FinanceMsg msg, FinanceModel model ) ->
            map FinanceModel FinanceMsg (Finance.update data msg model)

        ( MusicMsg msg, MusicModel model ) ->
            map MusicModel MusicMsg (Hebamp.update data msg model)

        ( CtrlPanelMsg msg, CtrlPanelModel model ) ->
            map CtrlPanelModel CtrlPanelMsg (CtrlPanel.update data msg model)

        ( ServersGearsMsg msg, ServersGearsModel model ) ->
            map ServersGearsModel ServersGearsMsg (ServersGears.update data msg model)

        ( LocationPickerMsg msg, LocationPickerModel model ) ->
            map LocationPickerModel LocationPickerMsg (LocationPicker.update data msg model)

        _ ->
            ( model, Cmd.none, Dispatch.none )


appLoaded :
    String
    -> Game.Data
    -> AppModel
    -> ( AppModel, Cmd Msg, Dispatch )
appLoaded wId data model =
    case model of
        LocationPickerModel model ->
            map LocationPickerModel LocationPickerMsg (LocationPicker.loaded wId data model)

        MusicModel model ->
            map MusicModel MusicMsg (Hebamp.loaded wId data model)

        _ ->
            ( model, Cmd.none, Dispatch.none )


map :
    (model -> AppModel)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( AppModel, Cmd Msg, Dispatch )
map wrapModel wrapMsg ( model, cmd, dispatch ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, dispatch )
