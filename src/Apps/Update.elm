module Apps.Update exposing (update)

import Game.Models exposing (GameModel)
import Core.Messages exposing (CoreMsg)
import Apps.Models exposing (..)
import Apps.Messages exposing (AppMsg(..))
import Apps.LogViewer.Update as LogViewer


update :
    AppMsg
    -> GameModel
    -> AppModel
    -> ( AppModel, Cmd AppMsg, List CoreMsg )
update msg game model =
    case ( msg, model ) of
        ( LogViewerMsg msg, LogViewerModel model ) ->
            map LogViewerModel LogViewerMsg (LogViewer.update msg game model)


map :
    (model -> AppModel)
    -> (msg -> AppMsg)
    -> ( model, Cmd msg, List CoreMsg )
    -> ( AppModel, Cmd AppMsg, List CoreMsg )
map wrapModel wrapMsg ( model, cmd, msgs ) =
    ( wrapModel model, Cmd.map wrapMsg cmd, msgs )
