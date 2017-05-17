module Apps.Browser.Context.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Core.Messages exposing (CoreMsg)
import Game.Models exposing (GameModel)
import Apps.Browser.Context.Models exposing (Model)
import Apps.Browser.Context.Messages exposing (Msg(..))
import Apps.Browser.Context.Actions exposing (actionHandler)


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
