module Apps.TaskManager.Update exposing (update)

import Time exposing (Time)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.TaskManager.Models
    exposing
        ( Model
        , updateTasks
        )
import Apps.TaskManager.Messages as TaskManager exposing (Msg(..))
import Apps.TaskManager.Menu.Messages as Menu
import Apps.TaskManager.Menu.Update as Menu
import Apps.TaskManager.Menu.Actions as Menu


type alias UpdateResponse =
    ( Model, Cmd TaskManager.Msg, Dispatch )


update :
    Game.Data
    -> TaskManager.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            onMenuMsg data msg model

        --- Every update
        Tick now ->
            onTick data now model


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


onTick : Game.Data -> Time -> Model -> UpdateResponse
onTick data now model =
    let
        activeServer =
            Game.getActiveServer data

        model_ =
            updateTasks
                activeServer
                model
    in
        ( model_, Cmd.none, Dispatch.none )
