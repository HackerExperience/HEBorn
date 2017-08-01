module Setup.Update exposing (update)

import Json.Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Gloc
import Setup.Models exposing (..)
import Setup.Messages exposing (..)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
        MapClick value ->
            let
                model_ =
                    value
                        |> Map.decodeCoordinates
                        |> Result.toMaybe
                        |> flip setPos model
            in
                ( model_, Cmd.none, Dispatch.none )

        GeoResp value ->
            --if Gloc.checkInstance value "setup" then DO else ( model, Cmd.none, Dispatch.none )
            geoResp value model

        _ ->
            ( model, Cmd.none, Dispatch.none )


geoResp : Value -> Model -> ( Model, Cmd Msg, Dispatch )
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
                            ( "setupmap", lat, lng, 18 )
                        ]

                Nothing ->
                    Cmd.none
    in
        ( model_, cmd, Dispatch.none )
