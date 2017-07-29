module Apps.LocationPicker.Update exposing (update)

import Json.Decode exposing (Value, decodeValue, float)
import Json.Decode.Pipeline exposing (decode, required)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Geolocation
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

        MapClick value ->
            let
                model_ =
                    value
                        |> decodeCoordinates
                        |> Result.toMaybe
                        |> flip setPos model
            in
                ( model_, Cmd.none, Dispatch.none )

        GeoResp value ->
            let
                newPos =
                    value
                        |> decodeCoordinates
                        |> Result.toMaybe

                model_ =
                    setPos newPos model

                cmd =
                    case newPos of
                        Just { lat, lng } ->
                            Cmd.batch
                                [ Geolocation.geoStop ""
                                , Map.mapCenter
                                    ( app.mapEId, lat, lng, 18 )
                                ]

                        Nothing ->
                            Cmd.none
            in
                ( model_, cmd, Dispatch.none )


decodeCoordinates : Value -> Result String Coordinates
decodeCoordinates =
    decode Coordinates
        |> required "lat" float
        |> required "lng" float
        |> decodeValue
