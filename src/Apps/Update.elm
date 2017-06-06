module Apps.Update exposing (update)

import Game.Models exposing (GameModel)
import Core.Messages exposing (CoreMsg)
import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.Update as LogViewer
import Apps.TaskManager.Update as TaskManager
import Apps.Browser.Update as Browser
import Apps.Explorer.Update as Explorer


update :
    AppMsg
    -> GameModel
    -> AppModel
    -> ( AppModel, Cmd AppMsg, List CoreMsg )
update msg game model =
    case ( msg, model ) of
        ( LogViewerMsg msg, LogViewerModel model ) ->
            map LogViewerModel LogViewerMsg (LogViewer.update msg game model)

        ( TaskManagerMsg msg, TaskManagerModel model ) ->
            map TaskManagerModel TaskManagerMsg (TaskManager.update msg game model)

        ( BrowserMsg msg, BrowserModel model ) ->
            map BrowserModel BrowserMsg (Browser.update msg game model)

        ( ExplorerMsg msg, ExplorerModel model ) ->
            map ExplorerModel ExplorerMsg (Explorer.update msg game model)

        _ ->
            ( model, Cmd.none, [] )


map :
    (model -> AppModel)
    -> (msg -> AppMsg)
    -> ( model, Cmd msg, List CoreMsg )
    -> ( AppModel, Cmd AppMsg, List CoreMsg )
map wrapModel wrapMsg ( model, cmd, msgs ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, msgs )
