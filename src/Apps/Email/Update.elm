module Apps.Email.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.Email.Models exposing (Model)
import Apps.Email.Messages as Email exposing (Msg(..))
import Apps.Email.Menu.Messages as Menu
import Apps.Email.Menu.Update as Menu
import Apps.Email.Menu.Actions as Menu


update :
    Game.Data
    -> Email.Msg
    -> Model
    -> ( Model, Cmd Email.Msg, Dispatch )
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
