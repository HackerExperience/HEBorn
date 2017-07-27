module Apps.LocationPicker.Update exposing (update)

import Json.Decode as D exposing (decodeValue)
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

        -- Map
        MapClick v ->
            let
                pos =
                    decodeValue latLngDecoder v
                        |> resToMaybe
            in
                ( setPos pos model, Cmd.none, Dispatch.none )

        GeoResp v ->
            let
                pos =
                    decodeValue latLngDecoder v
                        |> resToMaybe

                cmd =
                    case pos of
                        Just pos ->
                            Cmd.batch
                                [ Geolocation.geoStop ""
                                , Map.mapCenter ( app.mapEId, pos.lat, pos.lng, 18 )
                                ]

                        Nothing ->
                            Cmd.none
            in
                ( setPos pos model, cmd, Dispatch.none )


latLngDecoder : D.Decoder LatLng
latLngDecoder =
    decode LatLng
        |> required "lat" D.float
        |> required "lng" D.float


setPos : Maybe LatLng -> Model -> Model
setPos pos ({ app } as model) =
    let
        app_ =
            { app | pos = pos }
    in
        { model | app = app_ }


resToMaybe : Result a b -> Maybe b
resToMaybe =
    Result.map Just >> Result.withDefault Nothing
