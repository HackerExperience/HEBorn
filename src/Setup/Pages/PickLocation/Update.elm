module Setup.Pages.PickLocation.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.React as React exposing (React)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Game.Models as Game
import Setup.Pages.PickLocation.Config exposing (..)
import Setup.Pages.PickLocation.Models exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        MapClick value ->
            onMapClick config value model

        GeoLocResp value ->
            onGeoLocResp config value model

        GeoRevResp value ->
            onGeoRevResp config value model

        ResetLoc ->
            onResetLocation model

        Checked maybeLabel ->
            ( setAreaLabel maybeLabel model, React.none )


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
        ( model_, React.cmd cmd )


onGeoLocResp : Config msg -> Value -> Model -> UpdateResponse msg
onGeoLocResp config value model =
    -- TODO: add check location here
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
        ( model_, React.cmd cmd )


onGeoRevResp : Config msg -> Value -> Model -> UpdateResponse msg
onGeoRevResp config value model =
    value
        |> decodeLabel
        |> Result.toMaybe
        |> flip setAreaLabel model
        |> flip (,) React.none


onResetLocation : Model -> UpdateResponse msg
onResetLocation model =
    ( setAreaLabel Nothing model, React.none )
