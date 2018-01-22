module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Utils.React as React exposing (React)
import Apps.TaskManager.Menu.Config exposing (..)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


type alias UpdateResponse msg =
    ( Model, React msg )


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> UpdateResponse msg
actionHandler config action model =
    case action of
        PauseProcess pID ->
            pID
                |> config.onPauseProcess
                |> React.msg
                |> (,) model

        ResumeProcess pID ->
            pID
                |> config.onResumeProcess
                |> React.msg
                |> (,) model

        RemoveProcess pID ->
            pID
                |> config.onRemoveProcess
                |> React.msg
                |> (,) model
