module Apps.Explorer.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Explorer.Menu.Models exposing (Model)
import Apps.Explorer.Menu.Messages exposing (Msg(..))
import Apps.Explorer.Menu.Actions exposing (actionHandler)


update : Msg -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
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
