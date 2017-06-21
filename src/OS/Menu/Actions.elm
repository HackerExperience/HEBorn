module OS.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import OS.Models exposing (Model)
import OS.Messages exposing (..)
import OS.Menu.Messages exposing (MenuAction(..))


actionHandler : MenuAction -> Model -> Game.Model -> ( Model, Cmd Msg, Dispatch )
actionHandler action model game =
    case action of
        NoOp ->
            ( model, Cmd.none, Dispatch.none )
