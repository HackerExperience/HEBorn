module Apps.TaskManager.Update exposing (update)

import Dict
import Time exposing (Time)
import Utils exposing (andThenWithDefault)
import Core.Dispatcher exposing (callProcesses)
import Core.Messages as Core
import Game.Models as Game
import Game.Servers.Models exposing (getServerByID, getProcesses)
import Game.Servers.Processes.Types.Local exposing (ProcessState(StateRunning))
import Game.Servers.Processes.Models exposing (Processes, ProcessProp(LocalProcess))
import Game.Servers.Processes.Messages as Processes exposing (Msg(..))
import Apps.TaskManager.Models
    exposing
        ( Model
        , onlyLocalTasks
        , updateTasks
        )
import Apps.TaskManager.Messages as TaskManager exposing (Msg(..))
import Apps.TaskManager.Menu.Messages as MsgMenu
import Apps.TaskManager.Menu.Update
import Apps.TaskManager.Menu.Actions exposing (actionHandler)


processComplete : Processes -> Time -> List Core.Msg
processComplete tasks now =
    List.filterMap
        (\process ->
            case process.prop of
                LocalProcess prop ->
                    if
                        (prop.state == StateRunning)
                            && (andThenWithDefault (\eta -> now > (Debug.log "ETA: " eta)) False prop.eta)
                    then
                        Just (callProcesses "localhost" (Processes.Complete process.id))
                    else
                        Nothing

                _ ->
                    Nothing
        )
        (Dict.values tasks)


update : TaskManager.Msg -> Game.Model -> Model -> ( Model, Cmd TaskManager.Msg, List Core.Msg )
update msg game ({ app } as model) =
    case msg of
        -- -- Context
        MenuMsg (MsgMenu.MenuClick action) ->
            actionHandler action model game

        MenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.TaskManager.Menu.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        --- Every update
        Tick now ->
            let
                newApp =
                    updateTasks
                        game.servers
                        --TODO: Recalculate limits
                        app.limits
                        app

                server =
                    getServerByID game.servers "localhost"

                tasks =
                    getProcesses server

                completeMsgs =
                    case tasks of
                        Just tasks ->
                            processComplete tasks now

                        Nothing ->
                            []
            in
                ( { model | app = newApp }, Cmd.none, completeMsgs )
