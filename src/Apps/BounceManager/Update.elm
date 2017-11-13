module Apps.BounceManager.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.BounceManager.Models exposing (Model)
import Apps.BounceManager.Messages as BounceManager exposing (Msg(..))
import Apps.BounceManager.Menu.Messages as Menu
import Apps.BounceManager.Menu.Update as Menu
import Apps.BounceManager.Menu.Actions as Menu


update :
    Game.Data
    -> BounceManager.Msg
    -> Model
    -> ( Model, Cmd BounceManager.Msg, Dispatch )
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

        GoTab tab ->
            let
                model_ =
                    { model | selected = tab }
            in
                ( model_, Cmd.none, Dispatch.none )
