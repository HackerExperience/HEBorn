module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Game.Data as Game
import Apps.TaskManager.Config
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> UpdateResponse msg
actionHandler data action model =
    case action of
        PauseProcess pID ->
            let
                gameMsg =
                    pID
                        |> Servers.PauseProcess
                        |> Dispatch.processes config.activeCId
            in
                ( model, Cmd.none, gameMsg )

        ResumeProcess pID ->
            let
                gameMsg =
                    pID
                        |> Servers.ResumeProcess
                        |> Dispatch.processes config.activeCId
            in
                ( model, Cmd.none, gameMsg )

        RemoveProcess pID ->
            let
                gameMsg =
                    pID
                        |> Servers.RemoveProcess
                        |> Dispatch.processes config.activeCId
            in
                ( model, Cmd.none, gameMsg )
