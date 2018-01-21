module OS.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Game.Data as GameData
import OS.Config exposing (..)
import OS.Menu.Models exposing (Model)
import OS.Menu.Messages exposing (Msg(..))
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
            in
                ( { model | menu = menu_ }, Cmd.map MenuMsg cmd, Dispatch.none )

        MenuClick action ->
            ( model, Cmd.none, Dispatch.none )
