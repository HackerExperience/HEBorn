module Apps.LogFlix.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.LogFlix.Models exposing (..)
import Apps.LogFlix.Messages as LogFlix exposing (Msg(..))
import Apps.LogFlix.Menu.Messages as Menu
import Apps.LogFlix.Menu.Update as Menu
import Apps.LogFlix.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update :
    Game.Data
    -> LogFlix.Msg
    -> Model
    -> ( Model, Cmd LogFlix.Msg, Dispatch )
update data msg model =
    case msg of
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        UpdateTextFilter filter ->
            onUpdateFilter data filter model

        GoTab tab ->
            onGoTabs data tab model


onGoTabs : Game.Data -> MainTab -> Model -> UpdateResponse
onGoTabs data tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, Cmd.none, Dispatch.none )


onUpdateFilter : Game.Data -> String -> Model -> UpdateResponse
onUpdateFilter data filter model =
    Update.fromModel model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, dispatch ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, dispatch )
