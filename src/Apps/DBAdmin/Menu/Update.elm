module Apps.DBAdmin.Menu.Update exposing (update)

import ContextMenu exposing (ContextMenu)
import Utils.React as React exposing (React)
import Apps.DBAdmin.Menu.Config exposing (..)
import Apps.DBAdmin.Menu.Models exposing (Model)
import Apps.DBAdmin.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Config msg -> Msg -> Model -> ( Model, React msg )
update { toMsg } msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu

                react_ =
                    React.cmd <| Cmd.map (MenuMsg >> toMsg) cmd
            in
                ( { model | menu = menu_ }, react_ )

        MenuClick action ->
            ( model, React.none )
