module Apps.LocationPicker.Update exposing (update)

import Utils.React as React exposing (React)
import Json.Decode exposing (Value)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Gloc
import Game.Data as Game
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

        GeoResp value ->
            onGeoResp config value model


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


onGeoResp : Config msg -> Value -> Model -> UpdateResponse msg
onGeoResp config value model =
    if Gloc.checkInstance value model.self then
        geoResp config value model
    else
        ( model, React.none )


geoResp : Config msg -> Value -> Model -> UpdateResponse msg
geoResp config value model =
    let
        newPos =
            value
                |> Map.decodeCoordinates
                |> Result.toMaybe

        model_ =
            setPos newPos model

        react =
            case newPos of
                Just { lat, lng } ->
                    --[ Map.mapCenter ( model.mapEId, lat, lng, 18 ) ]
                    --    |> List.map React.cmd
                    --    |> React.batch config.batchMsg
                    React.none

                Nothing ->
                    React.none
    in
        ( model_, react )
