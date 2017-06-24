module Apps.Explorer.Update exposing (update)

import Game.Models as Game
import Game.Servers.Models exposing (getServerByID)
import Apps.Explorer.Models exposing (Model, changePath)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Menu.Update as Menu
import Apps.Explorer.Menu.Actions exposing (actionHandler)
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg ({ app } as model) =
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            actionHandler game action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update game msg model.menu

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
                ( { model | app = newApp }, Cmd.none, Dispatch.none )
