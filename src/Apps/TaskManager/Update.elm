module Apps.TaskManager.Update exposing (update)

import Dict
import Time exposing (Time)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Game.Servers.Shared as Servers
import Game.Servers.Models as Servers
import Game.Servers.Processes.Models as Processes
import Game.Servers.Processes.Messages as Processes
import Apps.TaskManager.Models
    exposing
        ( Model
        , onlyLocalTasks
        , updateTasks
        )
import Apps.TaskManager.Messages as TaskManager exposing (Msg(..))
import Apps.TaskManager.Menu.Messages as Menu
import Apps.TaskManager.Menu.Update as Menu
import Apps.TaskManager.Menu.Actions as Menu


processComplete : Servers.CId -> Processes.Model -> Time -> Dispatch
processComplete cid processes now =
    let
        complete ( id, proc ) =
            let
                completion =
                    Processes.getCompletionDate proc

                isCompleted =
                    Maybe.map ((>) now) completion
                        |> Maybe.withDefault False
            in
                case Processes.getState proc of
                    Processes.Running ->
                        if isCompleted then
                            Just <|
                                Dispatch.processes cid <|
                                    Processes.Complete id
                        else
                            Nothing

                    _ ->
                        Nothing
    in
        processes
            |> Processes.toList
            |> List.filterMap complete
            |> Dispatch.batch


update :
    Game.Data
    -> TaskManager.Msg
    -> Model
    -> ( Model, Cmd TaskManager.Msg, Dispatch )
update data msg ({ app } as model) =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        --- Every update
        Tick now ->
            let
                newApp =
                    updateTasks
                        data.server
                        --TODO: Recalculate limits
                        app.limits
                        app

                completeMsgs =
                    processComplete
                        (Game.getActiveCId data)
                        (Servers.getProcesses data.server)
                        now
            in
                ( { model | app = newApp }, Cmd.none, completeMsgs )
