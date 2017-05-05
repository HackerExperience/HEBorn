module OS.Context.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import OS.Models exposing (Model)
import OS.Messages exposing (OSMsg)
import OS.Context.Messages exposing (MenuAction(..))


actionHandler : MenuAction -> Model -> GameModel -> ( Model, Cmd OSMsg, List CoreMsg )
actionHandler action model game =
    case action of
        NoOp ->
            ( model, Cmd.none, [] )
