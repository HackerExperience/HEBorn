module Apps.Bug.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Bug.Models exposing (Model)
import Apps.Bug.Messages as Hackerbug exposing (Msg)
import Apps.Bug.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Hackerbug.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
