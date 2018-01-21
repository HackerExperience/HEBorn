module Apps.TaskManager.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Game.Data as Game
import Apps.TaskManager.Menu.Config exposing (..)
import Apps.TaskManager.Menu.Models exposing (Model)
import Apps.TaskManager.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse
update { toMsg } msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, Dispatch.none )

        MenuClick action ->
            ( model, Cmd.none, Dispatch.none )
