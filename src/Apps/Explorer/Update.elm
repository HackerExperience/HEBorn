module Apps.Explorer.Update exposing (update)

import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Game.Servers.Models exposing (getServerByID)
import Apps.Explorer.Models exposing (Model, changePath)
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

        -- General Acts
        GoPath newPath ->
            let
                server =
                    getServerByID game.servers "localhost"

                newApp =
                    changePath
                        newPath
                        app
                        server
            in
                ( { model | app = newApp }, Cmd.none, [] )
