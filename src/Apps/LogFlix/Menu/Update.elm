module Apps.LogFlix.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Game.Data as Game
import Apps.LogFlix.Menu.Models exposing (Model, Menu)
import Apps.LogFlix.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Data -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    case msg of
        MenuMsg msg ->
            onMenuMsg data msg model

        MenuClick action ->
            onMenuClick data model


onMenuMsg : Game.Data -> ContextMenu.Msg Menu -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd ) =
            ContextMenu.update msg model.menu

        model_ =
            { model | menu = menu_ }
    in
        ( model_, Cmd.map MenuMsg cmd, Dispatch.none )


onMenuClick : Game.Data -> Model -> UpdateResponse
onMenuClick data model =
    ( model, Cmd.none, Dispatch.none )
