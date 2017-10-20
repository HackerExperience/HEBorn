module Setup.Pages.PickLocation.Update exposing (update)

import Json.Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Update as Update
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Pages.PickLocation.Config exposing (..)
import Setup.Pages.PickLocation.Models exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Game.Model -> Msg -> Model -> UpdateResponse msg
update config game msg model =
    case msg of
        MapClick value ->
            onMapClick config value model

        GeoLocResp value ->
            onGeoLocResp config value model

        GeoRevResp value ->
            onGeoRevResp config value model

        ResetLoc ->
            ( model, geoLocReq geoInstance, Dispatch.none )


onMapClick : Config msg -> Value -> Model -> UpdateResponse msg
onMapClick config value model =
    let
        model_ =
            value
                |> Map.decodeCoordinates
                |> Result.toMaybe
                |> flip setCoords model

        cmd =
            case model_.coordinates of
                Just coords ->
                    geoRevReq
                        ( geoInstance, coords.lat, coords.lng )

                _ ->
                    Cmd.none
    in
        ( model_, cmd, Dispatch.none )


onGeoLocResp : Config msg -> Value -> Model -> UpdateResponse msg
onGeoLocResp config value model =
    let
        newPos =
            value
                |> Map.decodeCoordinates
                |> Result.toMaybe

        model_ =
            setCoords newPos model

        cmd =
            case newPos of
                Just { lat, lng } ->
                    Cmd.batch
                        [ Map.mapCenter
                            ( mapId, lat, lng, 18 )
                        , geoRevReq
                            ( geoInstance, lat, lng )
                        ]

                Nothing ->
                    Cmd.none
    in
        ( model_, cmd, Dispatch.none )


onGeoRevResp : Config msg -> Value -> Model -> UpdateResponse msg
onGeoRevResp config value model =
    value
        |> decodeLabel
        |> Result.toMaybe
        |> flip setAreaLabel model
        |> Update.fromModel
