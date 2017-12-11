module Apps.BounceManager.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.BounceManager.Models exposing (Model, MainTab)
import Apps.BounceManager.Messages as BounceManager exposing (Msg(..))
import Apps.BounceManager.Menu.Messages as Menu
import Apps.BounceManager.Menu.Update as Menu
import Apps.BounceManager.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd BounceManager.Msg, Dispatch )


update :
    Game.Data
    -> BounceManager.Msg
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
            onGoTab tab model


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


onGoTab : MainTab -> Model -> UpdateResponse
onGoTab tab model =
    let
        model_ =
            { model | selected = tab }
    in
        ( model_, Cmd.none, Dispatch.none )
