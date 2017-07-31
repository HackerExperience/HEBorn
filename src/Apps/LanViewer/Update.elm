module Apps.LanViewer.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.LanViewer.Models exposing (Model)
import Apps.LanViewer.Messages as LanViewer exposing (Msg(..))
import Apps.LanViewer.Menu.Messages as Menu
import Apps.LanViewer.Menu.Update as Menu
import Apps.LanViewer.Menu.Actions as Menu


update :
    Game.Data
    -> LanViewer.Msg
    -> Model
    -> ( Model, Cmd LanViewer.Msg, Dispatch )
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
