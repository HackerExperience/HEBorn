module Apps.LogViewer.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.LogViewer.Menu.Models exposing (Model)
import Apps.LogViewer.Menu.Messages exposing (Msg(..))
import Apps.LogViewer.Menu.Actions exposing (actionHandler)


update : Msg -> Model -> GameModel -> ( Model, Cmd Msg, List CoreMsg )
update msg model game =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu
            in
                ( { model | menu = menu_ }, Cmd.map MenuMsg cmd, [] )

        MenuClick action id ->
            ( model, Cmd.none, [] )
