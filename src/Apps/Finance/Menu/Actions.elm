module Apps.Finance.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Finance.Models exposing (Model)
import Apps.Finance.Messages as Finance exposing (Msg)
import Apps.Finance.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd Finance.Msg, Dispatch )
actionHandler data action model =
    case action of
        Dummy ->
            ( model, Cmd.none, Dispatch.none )
