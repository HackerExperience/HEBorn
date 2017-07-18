module Apps.ServersGears.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.ServersGears.Models exposing (Model)
import Apps.ServersGears.Messages as ServersGears exposing (Msg(..))
import Apps.ServersGears.Menu.Messages as Menu
import Apps.ServersGears.Menu.Update as Menu
import Apps.ServersGears.Menu.Actions as Menu


update :
    Game.Data
    -> ServersGears.Msg
    -> Model
    -> ( Model, Cmd ServersGears.Msg, Dispatch )
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
