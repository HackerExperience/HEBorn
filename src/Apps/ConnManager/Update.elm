module Apps.ConnManager.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Utils.Update as Update
import Apps.ConnManager.Models exposing (Model)
import Apps.ConnManager.Messages as ConnManager exposing (Msg(..))
import Apps.ConnManager.Menu.Messages as Menu
import Apps.ConnManager.Menu.Update as Menu
import Apps.ConnManager.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd ConnManager.Msg, Dispatch )


update :
    Game.Data
    -> ConnManager.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        -- Filter
        _ ->
            Update.fromModel model


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
