module Apps.ServersGears.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.ServersGears.Models exposing (Model)
import Apps.ServersGears.Messages as ServersGears exposing (Msg)
import Apps.ServersGears.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd ServersGears.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
