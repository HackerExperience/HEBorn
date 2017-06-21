module OS.Menu.Actions exposing (actionHandler)

import Core.Messages as Core
import Game.Models as Game
import OS.Models exposing (Model)
import OS.Messages exposing (..)
import OS.Menu.Messages exposing (ActionMsg(..))


actionHandler : ActionMsg -> Model -> Game.Model -> ( Model, Cmd Msg, List Core.Msg )
actionHandler action model game =
    case action of
        NoOp ->
            ( model, Cmd.none, [] )
