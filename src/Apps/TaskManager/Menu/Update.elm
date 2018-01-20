module Apps.TaskManager.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Game.Data as Game
import Apps.TaskManager.Menu.Models exposing (Model)
import Apps.TaskManager.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu
            in
                ( { model | menu = menu_ }, Cmd.map MenuMsg cmd, Dispatch.none )

        MenuClick action ->
            ( model, Cmd.none, Dispatch.none )
