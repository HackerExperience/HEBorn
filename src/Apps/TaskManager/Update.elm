module Apps.TaskManager.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Servers.Processes.Models exposing (initialProcesses)
import Apps.TaskManager.Models
    exposing
        ( Model
        , updateTasks
        )
import Apps.TaskManager.Messages exposing (Msg(..))
import Apps.TaskManager.Menu.Messages as MsgMenu
import Apps.TaskManager.Menu.Update
import Apps.TaskManager.Menu.Actions exposing (actionHandler)


update : Msg -> GameModel -> Model -> ( Model, Cmd Msg, List CoreMsg )
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
        Tick _ ->
            let
                newApp =
                    updateTasks
                        game.servers
                        --TODO: Recalculate limits
                        app.limits
                        app
            in
                ( { model | app = newApp }, Cmd.none, [] )
