module Apps.TaskManager.Update exposing (update)

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
                activeServer =
                    Game.getActiveServer data

                app_ =
                    updateTasks
                        activeServer
                        app.limits
                        app
            in
                ( { model | app = app_ }, Cmd.none, Dispatch.none )
