module Apps.Explorer.Update exposing (update)

import Game.Data as Game
import Game.Servers.Models as Servers
import Apps.Explorer.Models exposing (Model, changePath)
import Apps.Explorer.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Messages as Menu
import Apps.Explorer.Menu.Update as Menu
import Apps.Explorer.Menu.Actions exposing (actionHandler)
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg ({ app } as model) =
    case msg of
        -- Menu
        MenuMsg (Menu.MenuClick action) ->
            actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )

        -- General Acts
        GoPath newPath ->
            let
                newApp =
                    changePath
                        newPath
                        (Servers.getFilesystem data.server)
                        app
            in
                ( { model | app = newApp }, Cmd.none, Dispatch.none )
