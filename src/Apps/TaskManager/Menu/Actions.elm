module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.TaskManager.Models
    exposing
        ( Model
        , pauseProcess
        , resumeProcess
        , removeProcess
        )
import Apps.TaskManager.Messages exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


actionHandler :
    MenuAction
    -> Model
    -> GameModel
    -> ( Model, Cmd Msg, List CoreMsg )
actionHandler action ({ app } as model) game =
    case action of
        PauseProcess pID ->
            let
                app_ =
                    pauseProcess app pID

                model_ =
                    { model | app = app_ }
            in
                ( model_, Cmd.none, [] )

        ResumeProcess pID ->
            let
                app_ =
                    resumeProcess app pID

                model_ =
                    { model | app = app_ }
            in
                ( model_, Cmd.none, [] )

        RemoveProcess pID ->
            let
                app_ =
                    removeProcess app pID

                model_ =
                    { model | app = app_ }
            in
                ( model_, Cmd.none, [] )
