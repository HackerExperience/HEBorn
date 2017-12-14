module Apps.LogFlix.Menu.Actions
    exposing
        ( actionHandler
        )

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.LogFlix.Models exposing (..)
import Apps.LogFlix.Messages as LogFlix exposing (Msg(..))
import Apps.LogFlix.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd LogFlix.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            Update.fromModel model
