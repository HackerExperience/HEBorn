module Apps.Explorer.Context.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg)
import Apps.Explorer.Context.Messages exposing (MenuAction(..))


actionHandler : MenuAction -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action model game =
    case action of
        DoA ->
            ( model, Cmd.none, [] )

        DoB ->
            ( model, Cmd.none, [] )
