module Apps.LogViewer.Menu.Update exposing (update)

import Utils.React as React exposing (React)
import ContextMenu exposing (ContextMenu)
import Apps.LogViewer.Menu.Config exposing (..)
import Apps.LogViewer.Menu.Models exposing (Model)
import Apps.LogViewer.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Config msg -> Msg -> Model -> ( Model, React msg )
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
