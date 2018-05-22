module Setup.Pages.PickLocation.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.React as React exposing (React)
import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation
import Setup.Pages.PickLocation.Config exposing (..)
import Setup.Pages.PickLocation.Models exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        ResetLoc ->
            onResetLocation model

        Checked maybeLabel ->
            ( setAreaLabel maybeLabel model, React.none )

        LeafletMsg id msg ->
            if id == mapId then
                onLeafletMsg config msg model
            else
                ( model, React.none )

        GeolocationMsg id msg ->
            if id == geoInstance then
                onGeolocationMsg config msg model
            else
                ( model, React.none )


onLeafletMsg : Config msg -> Leaflet.Msg -> Model -> UpdateResponse msg
onLeafletMsg config msg model =
    case msg of
        Leaflet.Clicked coords ->
            ( setCoords (Just coords) model
            , React.cmd <| Geolocation.getLabel geoInstance coords
            )

        _ ->
            ( model, React.none )


onGeolocationMsg : Config msg -> Geolocation.Msg -> Model -> UpdateResponse msg
onGeolocationMsg config msg model =
    case msg of
        Geolocation.Coordinates coords ->
            [ Leaflet.center mapId coords 18
            , Geolocation.getLabel geoInstance coords
            ]
                |> List.map React.cmd
                |> React.batch config.batchMsg
                |> (,) (setCoords (Just coords) model)

        Geolocation.Label name ->
            React.update <| setAreaLabel (Just name) model

        _ ->
            ( model, React.none )


onResetLocation : Model -> UpdateResponse msg
onResetLocation model =
    ( setAreaLabel Nothing model, React.none )
