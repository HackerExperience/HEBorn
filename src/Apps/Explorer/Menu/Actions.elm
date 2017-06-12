module Apps.Explorer.Menu.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg)
import Apps.Explorer.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action model game =
    case action of
        Dummy ->
            ( model, Cmd.none, [] )
