module OS.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import OS.Models exposing (Model)
import OS.Messages exposing (..)
import OS.Menu.Messages exposing (MenuAction(..))


actionHandler : Game.Model -> MenuAction -> Model -> ( Model, Cmd Msg, Dispatch )
actionHandler game action model =
    case action of
        NoOp ->
            ( model, Cmd.none, Dispatch.none )
