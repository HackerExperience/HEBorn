module Apps.Browser.Menu.Update exposing (update)

import Utils.React as React exposing (React)
import ContextMenu exposing (ContextMenu)
import Apps.Browser.Menu.Config exposing (..)
import Apps.Browser.Menu.Models exposing (Model)
import Apps.Browser.Menu.Messages exposing (Msg(..))


update : Config msg -> Msg -> Model -> ( Model, React msg )
update config msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, cmd ) =
                    ContextMenu.update msg model.menu

                react =
                    React.cmd <| Cmd.map (MenuMsg >> config.toMsg) cmd
            in
                ( { model | menu = menu_ }, react )

        MenuClick action ->
            ( model, React.none )
