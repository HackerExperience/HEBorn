module Apps.Browser.Context.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Instances.Models exposing (InstanceID)
import Apps.Browser.Models exposing (Model)
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Context.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> InstanceID
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action instance model game =
    case action of
        DoA ->
            ( model, Cmd.none, [] )

        DoB ->
            ( model, Cmd.none, [] )
