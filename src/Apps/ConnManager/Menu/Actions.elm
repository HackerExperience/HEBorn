module Apps.ConnManager.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages as ConnManager exposing (Msg)
import Apps.ConnManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd ConnManager.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
