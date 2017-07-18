module Apps.CtrlPanel.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.CtrlPanel.Models exposing (Model)
import Apps.CtrlPanel.Messages as CtrlPanel exposing (Msg)
import Apps.CtrlPanel.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd CtrlPanel.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
