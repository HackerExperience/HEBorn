module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Dispatcher exposing (callProcesses)
import Core.Messages exposing (CoreMsg)
import Game.Servers.Processes.Messages as Processes exposing (Msg(..))
import Game.Models exposing (GameModel)
import Apps.TaskManager.Models
    exposing
        ( Model
        , pauseProcess
        , resumeProcess
        , removeProcess
        )
import Apps.TaskManager.Messages as TaskManager exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> GameModel
    -> ( Model, Cmd TaskManager.Msg, List CoreMsg )
actionHandler action ({ app } as model) game =
    case action of
        PauseProcess pID ->
            let
                app_ =
                    pauseProcess app pID

                model_ =
                    { model | app = app_ }

                gameMsg =
                    callProcesses
                        "localhost"
                        (Processes.Pause pID)
            in
                ( model_, Cmd.none, [ gameMsg ] )

        ResumeProcess pID ->
            let
                app_ =
                    resumeProcess app pID

                model_ =
                    { model | app = app_ }

                gameMsg =
                    callProcesses
                        "localhost"
                        (Processes.Resume pID)
            in
                ( model_, Cmd.none, [ gameMsg ] )

        RemoveProcess pID ->
            let
                app_ =
                    removeProcess app pID

                model_ =
                    { model | app = app_ }

                gameMsg =
                    callProcesses
                        "localhost"
                        (Processes.Remove pID)
            in
                ( model_, Cmd.none, [ gameMsg ] )
