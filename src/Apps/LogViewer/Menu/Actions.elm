module Apps.LogViewer.Context.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Instances.Models exposing (InstanceID)
import Apps.LogViewer.Models exposing (Model)
import Apps.LogViewer.Messages exposing (Msg)
import Apps.LogViewer.Context.Messages exposing (MenuAction(..))


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
