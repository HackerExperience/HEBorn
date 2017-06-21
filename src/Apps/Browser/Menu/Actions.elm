module Apps.Browser.Menu.Actions exposing (actionHandler)

import Game.Models as Game
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Menu.Messages exposing (MenuAction(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


actionHandler :
    MenuAction
    -> Model
    -> Game.Model
    -> ( Model, Cmd Msg, Dispatch )
actionHandler action model game =
    case action of
        DoA ->
            ( model, Cmd.none, Dispatch.none )

        DoB ->
            ( model, Cmd.none, Dispatch.none )
