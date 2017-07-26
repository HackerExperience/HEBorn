module Apps.LocationPicker.Update exposing (update, loaded)

import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.LocationPicker.Models exposing (Model)
import Apps.LocationPicker.Messages as LocationPicker exposing (Msg(..))
import Apps.LocationPicker.Menu.Messages as Menu
import Apps.LocationPicker.Menu.Update as Menu
import Apps.LocationPicker.Menu.Actions as Menu


update :
    Game.Data
    -> LocationPicker.Msg
    -> Model
    -> ( Model, Cmd LocationPicker.Msg, Dispatch )
update data msg ({ app } as model) =
    case msg of
        -- -- Context
        MenuMsg (Menu.MenuClick action) ->
            Menu.actionHandler data action model

        MenuMsg msg ->
            let
                ( menu_, cmd, coreMsg ) =
                    Menu.update data msg model.menu

                cmd_ =
                    Cmd.map MenuMsg cmd
            in
                ( { model | menu = menu_ }, cmd_, coreMsg )


loaded :
    String
    -> Game.Data
    -> Model
    -> ( Model, Cmd LocationPicker.Msg, Dispatch )
loaded wId data ({ app } as model) =
    let
        app_ =
            { app | mapEId = Just <| toString wId }

        model_ =
            { model | app = app_ }
    in
        ( model_, Cmd.none, Dispatch.none )
