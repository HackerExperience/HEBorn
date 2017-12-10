module Apps.LanViewer.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.LanViewer.Models exposing (Model)
import Apps.LanViewer.Messages as LanViewer exposing (Msg(..))
import Apps.LanViewer.Menu.Messages as Menu
import Apps.LanViewer.Menu.Update as Menu
import Apps.LanViewer.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd LanViewer.Msg, Dispatch )


update :
    Game.Data
    -> LanViewer.Msg
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
