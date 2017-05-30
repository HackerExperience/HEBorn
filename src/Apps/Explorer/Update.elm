module Apps.Explorer.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callFilesystem)
import Game.Models exposing (GameModel)
import Game.Servers.Filesystem.Messages as Filesystem
import Apps.Explorer.Models exposing (Model)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Messages as MsgMenu
import Apps.Explorer.Menu.Update
import Apps.Explorer.Menu.Actions exposing (actionHandler)


update : Msg -> GameModel -> Model -> ( Model, Cmd Msg, List CoreMsg )
update msg game ({ app } as model) =
    case msg of
        -- Menu
        MenuMsg (MsgMenu.MenuClick action) ->
            actionHandler action model game

        MenuMsg subMsg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Apps.Explorer.Menu.Update.update subMsg model.menu game

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )
