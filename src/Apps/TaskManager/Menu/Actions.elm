module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Processes.Messages as Processes exposing (Msg(..))
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    Game.Data
    -> MenuAction
    -> Model
    -> ( Model, Cmd TaskManager.Msg, Dispatch )
actionHandler data action ({ app } as model) =
    case action of
        PauseProcess pID ->
            let
                gameMsg =
                    Dispatch.processes
                        (Game.getActiveCId data)
                        (Processes.Pause pID)
            in
                ( model, Cmd.none, gameMsg )

        ResumeProcess pID ->
            let
                gameMsg =
                    Dispatch.processes
                        (Game.getActiveCId data)
                        (Processes.Resume pID)
            in
                ( model, Cmd.none, gameMsg )

        RemoveProcess pID ->
            let
                gameMsg =
                    Dispatch.processes
                        (Game.getActiveCId data)
                        (Processes.Remove pID)
            in
                ( model, Cmd.none, gameMsg )
