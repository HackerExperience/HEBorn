module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
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
                    pID
                        |> Servers.PauseProcess
                        |> Dispatch.processes (Game.getActiveCId data)
            in
                ( model, Cmd.none, gameMsg )

        ResumeProcess pID ->
            let
                gameMsg =
                    pID
                        |> Servers.ResumeProcess
                        |> Dispatch.processes (Game.getActiveCId data)
            in
                ( model, Cmd.none, gameMsg )

        RemoveProcess pID ->
            let
                gameMsg =
                    pID
                        |> Servers.RemoveProcess
                        |> Dispatch.processes (Game.getActiveCId data)
            in
                ( model, Cmd.none, gameMsg )
