module Apps.CtrlPanel.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.CtrlPanel.Models exposing (Model)
import Apps.CtrlPanel.Messages as CtrlPanel exposing (Msg(..))
import Apps.CtrlPanel.Menu.Messages as Menu
import Apps.CtrlPanel.Menu.Update as Menu
import Apps.CtrlPanel.Menu.Actions as Menu


update :
    Game.Data
    -> CtrlPanel.Msg
    -> Model
    -> ( Model, Cmd CtrlPanel.Msg, Dispatch )
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
