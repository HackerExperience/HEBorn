module Apps.Popup.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Popup.Models exposing (Model)
import Apps.Popup.Messages as Popup exposing (Msg)
import Apps.Popup.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Popup.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
