module Apps.Finance.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Finance.Models exposing (Model)
import Apps.Finance.Messages as Finance exposing (Msg(..))
import Apps.Finance.Menu.Messages as Menu
import Apps.Finance.Menu.Update as Menu
import Apps.Finance.Menu.Actions as Menu


update :
    Game.Data
    -> Finance.Msg
    -> Model
    -> ( Model, Cmd Finance.Msg, Dispatch )
update data msg model =
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
