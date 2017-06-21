module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Dispatcher exposing (callProcesses)
import Core.Messages as Core
import Game.Models as Game
import Game.Servers.Processes.Messages as Processes exposing (Msg(..))
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> Game.Model
    -> ( Model, Cmd TaskManager.Msg, List Core.Msg )
actionHandler action ({ app } as model) game =
    case action of
        PauseProcess pID ->
            let
                gameMsg =
                    callProcesses
                        "localhost"
                        (Processes.Pause pID)
            in
                ( model, Cmd.none, [ gameMsg ] )

        ResumeProcess pID ->
            let
                gameMsg =
                    callProcesses
                        "localhost"
                        (Processes.Resume pID)
            in
                ( model, Cmd.none, [ gameMsg ] )

        RemoveProcess pID ->
            let
                gameMsg =
                    callProcesses
                        "localhost"
                        (Processes.Remove pID)
            in
                ( model, Cmd.none, [ gameMsg ] )
