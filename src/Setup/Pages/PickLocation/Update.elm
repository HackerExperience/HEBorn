module Setup.Pages.PickLocation.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Core as Core
import Core.Error as Error
import Game.Models as Game
import Utils.Update as Update
import Utils.Ports.Map as Map
import Utils.Maybe as Maybe
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Pages.PickLocation.Config exposing (..)
import Setup.Pages.PickLocation.Models exposing (..)
import Setup.Pages.PickLocation.Messages exposing (..)
import Setup.Pages.PickLocation.Requests exposing (..)
import Game.Servers.Settings.Check as Check
import Game.Servers.Settings.Set as Set
import Game.Servers.Settings.Types exposing (..)
import Game.Account.Models as Account


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

        Request data ->
            updateRequest config game (receive data) model


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



-- request handlers


updateRequest :
    Config msg
    -> Game.Model
    -> Maybe Response
    -> Model
    -> UpdateResponse msg
updateRequest config game mResponse model =
    case mResponse of
        Just (Check (Check.Valid value)) ->
            onCheckValid config game value model

        Just (Check (Check.Invalid reason)) ->
            Update.fromModel model

        Just (Set (Set.Valid _)) ->
            Update.fromModel <| setOkay model

        Just (Set (Set.Invalid _)) ->
            Update.fromModel model

        Nothing ->
            Update.fromModel model


onCheckValid : Config msg -> Game.Model -> Value -> Model -> UpdateResponse msg
onCheckValid config game value model =
    case Decode.decodeValue decodeLocation value of
        Ok address ->
            let
                coords =
                    getCoords model

                mainframe =
                    game
                        |> Game.getAccount
                        |> Account.getMainframe

                model_ =
                    setAreaLabel (Just address) model

                cmd =
                    case Maybe.uncurry mainframe coords of
                        Just ( cid, coords ) ->
                            setRequest config (Location coords) cid game

                        Nothing ->
                            Cmd.none
            in
                ( model_, cmd, Dispatch.none )

        Err reason ->
            let
                dispatch =
                    ("Can't parse location response: " ++ reason)
                        |> Error.porra
                        |> Core.Crash
                        |> Dispatch.core
            in
                ( model, Cmd.none, dispatch )
