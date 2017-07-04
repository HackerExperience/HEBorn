module Apps.BounceManager.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.BounceManager.Models exposing (Model)
import Apps.BounceManager.Messages as BounceManager exposing (Msg)
import Apps.BounceManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd BounceManager.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
