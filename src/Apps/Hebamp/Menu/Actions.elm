module Apps.Hebamp.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Hebamp.Models exposing (Model)
import Apps.Hebamp.Messages as Hebamp exposing (Msg)
import Apps.Hebamp.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Hebamp.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
