module Apps.TaskManager.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Core.Messages as Core
import Game.Models as Game
import Apps.TaskManager.Menu.Models exposing (Model)
import Apps.TaskManager.Menu.Messages exposing (Msg(..))


update : Msg -> Model -> Game.Model -> ( Model, Cmd Msg, List Core.Msg )
update msg model game =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu
            in
                ( { model | menu = menu_ }, Cmd.map MenuMsg cmd, [] )

        MenuClick action ->
            ( model, Cmd.none, [] )
