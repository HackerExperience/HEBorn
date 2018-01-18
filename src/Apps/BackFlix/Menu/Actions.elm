module Apps.BackFlix.Menu.Actions
    exposing
        ( actionHandler
        )

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.BackFlix.Models exposing (..)
import Apps.BackFlix.Messages as BackFlix exposing (Msg(..))
import Apps.BackFlix.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd BackFlix.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            Update.fromModel model
