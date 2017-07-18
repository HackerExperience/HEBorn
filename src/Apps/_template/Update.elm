module Apps.Template.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Template.Models exposing (Model)
import Apps.Template.Messages as Template exposing (Msg(..))
import Apps.Template.Menu.Messages as Menu
import Apps.Template.Menu.Update as Menu
import Apps.Template.Menu.Actions as Menu


update :
    Game.Data
    -> Template.Msg
    -> Model
    -> ( Model, Cmd Template.Msg, Dispatch )
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
