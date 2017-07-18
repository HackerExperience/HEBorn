module Apps.CtrlPanel.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Game.Data as Game
import Apps.CtrlPanel.Menu.Models exposing (Model)
import Apps.CtrlPanel.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu
            in
                ( { model | menu = menu_ }, Cmd.map MenuMsg cmd, Dispatch.none )

        MenuClick action ->
            ( model, Cmd.none, Dispatch.none )
