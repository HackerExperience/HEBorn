module Apps.LocationPicker.Update exposing (update)

import Json.Decode exposing (Value)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Gloc
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Data as Game
import Apps.LocationPicker.Models exposing (..)
import Apps.LocationPicker.Messages as LocationPicker exposing (Msg(..))


type alias UpdateResponse =
    ( Model, Cmd LocationPicker.Msg, Dispatch )


update :
    Game.Data
    -> LocationPicker.Msg
    -> Model
    -> UpdateResponse
update data msg model =
    case msg of
        -- -- Context
        MapClick value ->
            onMapClick value model

        GeoResp value ->
            onGeoResp value model


onMapClick : Value -> Model -> UpdateResponse
onMapClick value model =
    let
        model_ =
            value
                |> Map.decodeCoordinates
                |> Result.toMaybe
                |> flip setPos model
    in
        ( model_, Cmd.none, Dispatch.none )


onGeoResp : Value -> Model -> UpdateResponse
onGeoResp value model =
    if Gloc.checkInstance value model.self then
        geoResp value model
    else
        ( model, Cmd.none, Dispatch.none )


geoResp : Value -> Model -> UpdateResponse
geoResp value model =
    let
        newPos =
            value
                |> Map.decodeCoordinates
                |> Result.toMaybe

        model_ =
            setPos newPos model

        cmd =
            case newPos of
                Just { lat, lng } ->
                    Cmd.batch
                        [ Map.mapCenter
                            ( model.mapEId, lat, lng, 18 )
                        ]

                Nothing ->
                    Cmd.none
    in
        ( model_, cmd, Dispatch.none )
