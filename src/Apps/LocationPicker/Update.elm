module Apps.LocationPicker.Update exposing (update)

import Utils.React as React exposing (React)
import Json.Decode exposing (Value)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Geolocation
import Apps.LocationPicker.Config exposing (..)
import Apps.LocationPicker.Models exposing (..)
import Apps.LocationPicker.Messages as LocationPicker exposing (Msg(..))


type alias UpdateResponse msg =
    ( Model, React msg )


update :
    Config msg
    -> LocationPicker.Msg
    -> Model
    -> UpdateResponse msg
update config msg model =
    case msg of
        -- -- Context
        MapClick value ->
            onMapClick value model

        GeolocationMsg id msg ->
            if id == model.self then
                onGeoMsg config msg model
            else
                ( model, React.none )


onMapClick : Value -> Model -> UpdateResponse msg
onMapClick value model =
    let
        model_ =
            value
                |> Map.decodeCoordinates
                |> Result.toMaybe
                |> flip setPos model
    in
        ( model_, React.none )


onGeoMsg : Config msg -> Geolocation.Msg -> Model -> UpdateResponse msg
onGeoMsg config msg model =
    case msg of
        Geolocation.Coordinates lat lng ->
            ( model.mapEId, lat, lng, 18 )
                |> Map.mapCenter
                |> React.cmd
                |> (,) model

        _ ->
            ( model, React.none )
