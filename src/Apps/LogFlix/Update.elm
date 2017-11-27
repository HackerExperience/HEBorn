module Apps.LogFlix.Update exposing (update)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Servers as Servers
import Utils.Update as Update
import Game.Data as Game
import Apps.LogFlix.Models exposing (..)
import Apps.LogFlix.Messages as LogFlix exposing (Msg(..))
import Apps.LogFlix.Menu.Messages as Menu
import Apps.LogFlix.Menu.Update as Menu


update :
    Game.Data
    -> LogFlix.Msg
    -> Model
    -> ( Model, Cmd LogFlix.Msg, Dispatch )
update data msg model =
    case msg of
        -- Context
        --MenuMsg (Menu.MenuClick action) ->
        --    Menu.actionHandler data action model
        MenuMsg msg ->
            let
                ( menu_, cmd, dispatch ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd

                model_ =
                    { model | menu = menu_ }
            in
                ( model_, cmd_, dispatch )

        UpdateTextFilter filter ->
            model
                |> updateTextFilter data filter
                |> Update.fromModel

        GoTab tab ->
            let
                model_ =
                    { model | selected = tab }
            in
                ( model_, Cmd.none, Dispatch.none )

        DummyNoOp ->
            ( model, Cmd.none, Dispatch.none )
