module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Models
    exposing
        ( Model
        )
import Apps.TaskManager.Messages exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action ({ app } as model) game =
    case action of
        DoA ->
            ( model, Cmd.none, [] )
