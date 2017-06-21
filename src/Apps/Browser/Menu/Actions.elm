module Apps.Browser.Menu.Actions exposing (actionHandler)

import Core.Messages as Core
import Game.Models as Game
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> Game.Model
    -> ( Model, Cmd Msg, List Core.Msg )
actionHandler action model game =
    case action of
        DoA ->
            ( model, Cmd.none, [] )

        DoB ->
            ( model, Cmd.none, [] )
