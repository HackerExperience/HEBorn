module Apps.TaskManager.Menu.Actions exposing (actionHandler)

import Utils.React as React exposing (React)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Apps.TaskManager.Menu.Config exposing (..)
import Apps.TaskManager.Models exposing (Model)
import Apps.TaskManager.Messages as TaskManager exposing (Msg)
import Apps.TaskManager.Menu.Messages exposing (MenuAction(..))


type alias UpdateResponse msg =
    ( Model, React msg )



-- CONFREFACT : Change this dispatches for the new format


actionHandler :
    Config msg
    -> MenuAction
    -> Model
    -> UpdateResponse msg
actionHandler config action model =
    case action of
        PauseProcess pID ->
            --let
            --    gameMsg =
            --        pID
            --            |> Servers.PauseProcess
            --            |> Dispatch.processes config.activeCId
            --in
            ( model, React.none )

        ResumeProcess pID ->
            --let
            --    gameMsg =
            --        pID
            --            |> Servers.ResumeProcess
            --            |> Dispatch.processes config.activeCId
            --in
            ( model, React.none )

        RemoveProcess pID ->
            --  let
            --      gameMsg =
            --           pID
            --              |> Servers.RemoveProcess
            --              |> Dispatch.processes config.activeCId
            --  in
            ( model, React.none )
