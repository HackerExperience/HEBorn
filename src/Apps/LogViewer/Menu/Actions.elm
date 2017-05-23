module Apps.LogViewer.Menu.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages exposing (Msg)
import Apps.LogViewer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action model game =
    case action of
        DoA ->
            ( model, Cmd.none, [] )

        DoB ->
            ( model, Cmd.none, [] )
