module Apps.ConnManager.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages as ConnManager exposing (Msg(..))
import Apps.ConnManager.Menu.Messages as Menu
import Apps.ConnManager.Menu.Update as Menu
import Apps.ConnManager.Menu.Actions as Menu


update :
    Game.Data
    -> ConnManager.Msg
    -> Model
    -> ( Model, Cmd ConnManager.Msg, Dispatch )
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

        -- Filter
        _ ->
            ( model, Cmd.none, Dispatch.none )
