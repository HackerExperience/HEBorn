module Apps.Update exposing (update)

import Game.Data as Game
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Update as LogViewer
import Apps.TaskManager.Update as TaskManager
import Apps.Browser.Update as Browser
import Apps.Explorer.Update as Explorer
import Apps.DBAdmin.Update as Database
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Data
    -> Msg
    -> AppModel
    -> ( AppModel, Cmd Msg, Dispatch )
update data msg model =
    case ( msg, model ) of
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

        _ ->
            ( model, Cmd.none, Dispatch.none )


map :
    (model -> AppModel)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( AppModel, Cmd Msg, Dispatch )
map wrapModel wrapMsg ( model, cmd, dispatch ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, dispatch )
