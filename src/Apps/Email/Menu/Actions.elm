module Apps.Email.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Email.Models exposing (Model)
import Apps.Email.Messages as Email exposing (Msg)
import Apps.Email.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Email.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
