module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg(MsgGame))
import Game.Messages exposing (GameMsg(MsgServers))
import Game.Servers.Models exposing (ServerID)
import Game.Servers.Messages exposing (ServerMsg(MsgProcess))
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


msgProcesses : ServerID -> Processes.Msg -> CoreMsg
msgProcesses serverID msg =
    MsgProcess serverID msg
        |> MsgServers
        |> MsgGame


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
                    msgProcesses
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
                    msgProcesses
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
                    msgProcesses
                        "localhost"
                        (Processes.Remove pID)
            in
                ( model_, Cmd.none, [ gameMsg ] )
