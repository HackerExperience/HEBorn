module Setup.Update exposing (update)

import Json.Decode exposing (Value, decodeValue, float)
import Json.Decode.Pipeline exposing (decode, required)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Geolocation
import Setup.Models exposing (..)
import Setup.Messages exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
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
                                    ( "setupmap", lat, lng, 18 )
                                ]

                        Nothing ->
                            Cmd.none
            in
                ( model_, cmd, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


decodeCoordinates : Value -> Result String Coordinates
decodeCoordinates =
    decode Coordinates
        |> required "lat" float
        |> required "lng" float
        |> decodeValue
