module Apps.Explorer.Menu.Update exposing (update)

import Utils.React as React exposing (React)
import ContextMenu exposing (ContextMenu)
import Game.Data as Game
import Apps.Explorer.Menu.Config exposing (..)
import Apps.Explorer.Menu.Models exposing (Model)
import Apps.Explorer.Menu.Messages exposing (Msg(..))
import Core.Dispatch as Dispatch exposing (Dispatch)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update { toMsg } msg model =
    case msg of
        MenuMsg msg ->
            let
                ( menu_, react ) =
                    ContextMenu.update msg model.menu

                react_ =
                    React.cmd <| Cmd.map (MenuMsg >> toMsg) react
            in
                ( { model | menu = menu_ }, react_ )

        MenuClick action ->
            ( model, React.none )
