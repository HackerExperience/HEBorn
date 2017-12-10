module Apps.CtrlPanel.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.CtrlPanel.Models exposing (Model)
import Apps.CtrlPanel.Messages as CtrlPanel exposing (Msg(..))
import Apps.CtrlPanel.Menu.Messages as Menu
import Apps.CtrlPanel.Menu.Update as Menu
import Apps.CtrlPanel.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd CtrlPanel.Msg, Dispatch )


update :
    Game.Data
    -> CtrlPanel.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )
