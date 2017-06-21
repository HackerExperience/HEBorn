module Apps.Update exposing (update)

import Game.Models as Game
import Core.Messages as Core
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Update as LogViewer
import Apps.TaskManager.Update as TaskManager
import Apps.Browser.Update as Browser
import Apps.Explorer.Update as Explorer


update :
    Msg
    -> Game.Model
    -> AppModel
    -> ( AppModel, Cmd Msg, List Core.Msg )
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
    -> (msg -> Msg)
    -> ( model, Cmd msg, List Core.Msg )
    -> ( AppModel, Cmd Msg, List Core.Msg )
map wrapModel wrapMsg ( model, cmd, msgs ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, msgs )
