module Setup.Update exposing (update)

import Json.Decode exposing (Value)
import Utils.Update as Update
import Core.Messages as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Game.Models as Game
import Game.Account.Models as Account
import Utils.Ports.Map as Map
import Utils.Cmd as Cmd
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Types exposing (..)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        FinishLoading ->
            onFinishLoading game model

        HandleJoinedAccount ->
            handleJoinedAccount model

        _ ->
            ( model, Cmd.none, Dispatch.none )


onFinishLoading : Game.Model -> Model -> UpdateResponse
onFinishLoading game model =
    let
        account =
            Game.getAccount game

        pages =
            account
                |> Account.getSetupPages
                |> initializePages

        page =
            List.head pages

        model_ =
            { model | page = page, pages = pages }
    in
        if Account.needsSetup account then
            Update.fromModel model_
        else
            let
                dispatch =
                    Dispatch.core Core.FinishSetup
            in
                ( model, Cmd.none, dispatch )


handleJoinedAccount : Model -> UpdateResponse
handleJoinedAccount model =
    -- we have no order guarantees about dispatches, so an additional
    -- wait of X seconds is needed here :/
    let
        model_ =
            { model | isLoading = False }

        delay =
            Cmd.delay 1 FinishLoading
    in
        ( model_, delay, Dispatch.none )



--case msg of
--    MapClick value ->
--        mapClick value model
--    GeoLocResp value ->
--        geoLocResp value model
--    GeoRevResp value ->
--        geoRevResp value model
--    ResetLoc ->
--        ( model, geoLocReq geoInstance, Dispatch.none )
--    GoStep step ->
--        goStep step model
--    GoOS ->
--        let
--            dispatch =
--                Dispatch.core Core.FinishSetup
--        in
--            ( model, Cmd.none, dispatch )
--mapClick : Value -> Model -> ( Model, Cmd Msg, Dispatch )
--mapClick value model =
--    let
--        model_ =
--            value
--                |> Map.decodeCoordinates
--                |> Result.toMaybe
--                |> flip setCoords model
--        cmd =
--            case model_.coordinates of
--                Just coords ->
--                    geoRevReq
--                        ( geoInstance, coords.lat, coords.lng )
--                _ ->
--                    Cmd.none
--    in
--        ( model_, cmd, Dispatch.none )
--geoLocResp : Value -> Model -> ( Model, Cmd Msg, Dispatch )
--geoLocResp value model =
--    let
--        newPos =
--            value
--                |> Map.decodeCoordinates
--                |> Result.toMaybe
--        model_ =
--            setCoords newPos model
--        cmd =
--            case newPos of
--                Just { lat, lng } ->
--                    Cmd.batch
--                        [ Map.mapCenter
--                            ( mapId, lat, lng, 18 )
--                        , geoRevReq
--                            ( geoInstance, lat, lng )
--                        ]
--                Nothing ->
--                    Cmd.none
--    in
--        ( model_, cmd, Dispatch.none )
--geoRevResp : Value -> Model -> ( Model, Cmd Msg, Dispatch )
--geoRevResp value model =
--    let
--        model_ =
--            value
--                |> decodeLabel
--                |> Result.toMaybe
--                |> flip setAreaLabel model
--    in
--        ( model_, Cmd.none, Dispatch.none )
--goStep : Step -> Model -> ( Model, Cmd Msg, Dispatch )
--goStep step model =
--    let
--        model_ =
--            setStep step model
--        cmd =
--            if step == PickLocation then
--                mapInitCmd
--            else
--                Cmd.none
--    in
--        ( model_, cmd, Dispatch.none )
--mapInitCmd : Cmd Msg
--mapInitCmd =
--    Cmd.batch
--        [ Map.mapInit mapId
--        , geoLocReq geoInstance
--        ]
