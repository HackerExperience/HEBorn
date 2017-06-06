module Apps.TaskManager.Update exposing (update)

import Dict
import Utils exposing (andThenWithDefault)
import Core.Messages exposing (CoreMsg(MsgGame))
import Game.Models exposing (GameModel)
import Game.Messages exposing (GameMsg(MsgServers))
import Game.Servers.Models exposing (ServerID)
import Game.Servers.Messages exposing (ServerMsg(MsgProcess))
import Game.Servers.Processes.Types.Local exposing (ProcessState(StateRunning))
import Game.Servers.Processes.Models exposing (ProcessProp(LocalProcess))
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


msgProcesses : ServerID -> Processes.Msg -> CoreMsg
msgProcesses serverID msg =
    MsgProcess serverID msg
        |> MsgServers
        |> MsgGame


processComplete tasks now =
    List.filterMap
        (\process ->
            case process.prop of
                LocalProcess prop ->
                    if
                        (prop.state == StateRunning)
                            && (andThenWithDefault (\eta -> now > (Debug.log "ETA: " eta)) False prop.eta)
                    then
                        Just (msgProcesses "localhost" (Processes.Complete process.id))
                    else
                        Nothing

                _ ->
                    Nothing
        )
        (Dict.values tasks)


update : TaskManager.Msg -> GameModel -> Model -> ( Model, Cmd TaskManager.Msg, List CoreMsg )
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

                completeMsgs =
                    processComplete app.localTasks now
            in
                ( { model | app = newApp }, Cmd.none, completeMsgs )
