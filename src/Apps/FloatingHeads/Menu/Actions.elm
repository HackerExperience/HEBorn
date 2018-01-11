module Apps.FloatingHeads.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.FloatingHeads.Models exposing (Model)
import Apps.FloatingHeads.Messages as FloatingHeads exposing (Msg)
import Apps.FloatingHeads.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd FloatingHeads.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
