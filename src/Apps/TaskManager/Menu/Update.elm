module Apps.TaskManager.Menu.Update exposing (update)

import Utils.React as React exposing (React)
import ContextMenu exposing (ContextMenu)
import Apps.TaskManager.Menu.Config exposing (..)
import Apps.TaskManager.Menu.Models exposing (Model)
import Apps.TaskManager.Menu.Messages exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update { toMsg } msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu

                react =
                    React.cmd <| Cmd.map (MenuMsg >> toMsg) cmd
            in
                ( { model | menu = menu_ }, react )

        MenuClick action ->
            ( model, React.none )
