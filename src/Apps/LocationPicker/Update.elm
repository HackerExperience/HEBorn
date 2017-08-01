module Apps.LocationPicker.Update exposing (update)

import Json.Decode exposing (Value)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation as Gloc
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
            if Gloc.checkInstance value model.self then
                geoResp value model
            else
                ( model, Cmd.none, Dispatch.none )


geoResp : Value -> Model -> ( Model, Cmd LocationPicker.Msg, Dispatch )
geoResp value ({ app } as model) =
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
                            ( app.mapEId, lat, lng, 18 )
                        ]

                Nothing ->
                    Cmd.none
    in
        ( model_, cmd, Dispatch.none )
