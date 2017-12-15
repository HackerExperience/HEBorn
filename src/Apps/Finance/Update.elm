module Apps.Finance.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Utils.Update as Update
import Game.Data as Game
import Apps.Finance.Models exposing (Model, MainTab)
import Apps.Finance.Messages as Finance exposing (Msg(..))
import Apps.Finance.Menu.Messages as Menu
import Apps.Finance.Menu.Update as Menu
import Apps.Finance.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd Finance.Msg, Dispatch )


update :
    Game.Data
    -> Finance.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        GoTab tab ->
            onGoTabs data tab model


onMenuMsg : Game.Data -> Menu.Msg -> Model -> UpdateResponse
onMenuMsg data msg model =
    let
        ( menu_, cmd, coreMsg ) =
            Menu.update data msg model.menu

        cmd_ =
            Cmd.map MenuMsg cmd

        model_ =
            { model | menu = menu_ }
    in
        ( model_, cmd_, coreMsg )


onGoTabs : Game.Data -> MainTab -> Model -> UpdateResponse
onGoTabs data tab model =
    let
        model_ =
            { model | selected = tab }
    in
        Update.fromModel model_
