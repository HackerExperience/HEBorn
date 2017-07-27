module Apps.LocationPicker.Update exposing (update)

import Json.Decode as D exposing (decodeValue)
import Json.Decode.Pipeline exposing (decode, required)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.LocationPicker.Models exposing (..)
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

        -- Map
        MapClick v ->
            let
                decoder =
                    decode LatLng
                        |> required "lat" D.float
                        |> required "lng" D.float

                pos =
                    decodeValue decoder v
                        |> Result.map Just
                        |> Result.withDefault Nothing

                app_ =
                    { app | pos = pos }

                model_ =
                    { model | app = app_ }
            in
                ( model_, Cmd.none, Dispatch.none )
