module Setup.Pages.PickLocation.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.React as React exposing (React)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Geolocation
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

        GeolocationMsg id msg ->
            if id == mapId then
                onGeolocationMsg config msg model
            else
                ( model, React.none )

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
                    Geolocation.getLabel mapId coords.lat coords.lng

                _ ->
                    Cmd.none
    in
        ( model_, React.cmd cmd )


onGeolocationMsg : Config msg -> Geolocation.Msg -> Model -> UpdateResponse msg
onGeolocationMsg config msg model =
    case msg of
        Geolocation.Coordinates lat lng ->
            [ Map.mapCenter ( mapId, lat, lng, 18 )
            , Geolocation.getLabel mapId lat lng
            ]
                |> List.map React.cmd
                |> React.batch config.batchMsg
                |> (,) (setCoords (Just { lat = lat, lng = lng }) model)

        Geolocation.Label name ->
            React.update <| setAreaLabel (Just name) model

        _ ->
            ( model, React.none )


onResetLocation : Model -> UpdateResponse msg
onResetLocation model =
    ( setAreaLabel Nothing model, React.none )
