module Apps.Update exposing (update)

import Game.Models as Game
import Apps.Models exposing (..)
import Apps.Messages exposing (..)
import Apps.LogViewer.Update as LogViewer
import Apps.TaskManager.Update as TaskManager
import Apps.Browser.Update as Browser
import Apps.Explorer.Update as Explorer
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Msg
    -> Game.Model
    -> AppModel
    -> ( AppModel, Cmd Msg, Dispatch )
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
            ( model, Cmd.none, Dispatch.none )


map :
    (model -> AppModel)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( AppModel, Cmd Msg, Dispatch )
map wrapModel wrapMsg ( model, cmd, msgs ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, msgs )
