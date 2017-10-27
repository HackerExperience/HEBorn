module Setup.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.Update as Update
import Core.Messages as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Core as Core
import Game.Models as Game
import Game.Account.Models as Account
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)
import Setup.Pages.Configs as Configs
import Setup.Pages.PickLocation.Update as PickLocation
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Update as Mainframe
import Setup.Pages.Mainframe.Messages as Mainframe
import Setup.Requests.Setup as Setup
import Setup.Requests exposing (..)
import Decoders.Account


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        NextPage ->
            onNextPage game model

        PreviousPage ->
            onPreviousPage game model

        MainframeMsg msg ->
            onMainframeMsg game msg model

        PickLocationMsg msg ->
            onPickLocationMsg game msg model

        HandleJoinedAccount value ->
            if isLoading model then
                handleJoinedAccount value model
            else
                Update.fromModel model

        Request data ->
            updateRequest game (receive data) model



-- message handlers


onNextPage : Game.Model -> Model -> UpdateResponse
onNextPage game model =
    let
        resultEncodedPage =
            model.page
                |> Result.fromMaybe "No page to convert"
                |> Result.andThen encodePageModel

        model_ =
            nextPage model

        dispatch =
            if doneSetup model_ then
                Dispatch.core Core.Play
            else
                Dispatch.none

        cmd =
            case resultEncodedPage of
                Ok pageNameValue ->
                    let
                        accountId =
                            game
                                |> Game.getAccount
                                |> Account.getId
                    in
                        Setup.request pageNameValue accountId game

                Err _ ->
                    Cmd.none

        cmd_ =
            Cmd.batch
                [ cmd
                , locationPickerCmd model_
                ]
    in
        ( model_, cmd_, dispatch )


onPreviousPage : Game.Model -> Model -> UpdateResponse
onPreviousPage game model =
    let
        model_ =
            previousPage model

        cmd =
            locationPickerCmd model_
    in
        ( model_, cmd, Dispatch.none )



-- child message handlers


onMainframeMsg : Game.Model -> Mainframe.Msg -> Model -> UpdateResponse
onMainframeMsg game msg model =
    case model.page of
        Just (MainframeModel page) ->
            let
                ( page_, cmd_, dispatch ) =
                    Mainframe.update Configs.setMainframeName game msg page

                model_ =
                    setPage (MainframeModel page_) model
            in
                ( model_, cmd_, dispatch )

        _ ->
            Update.fromModel model


onPickLocationMsg : Game.Model -> PickLocation.Msg -> Model -> UpdateResponse
onPickLocationMsg game msg model =
    case model.page of
        Just (PickLocationModel page) ->
            let
                ( page_, cmd_, dispatch ) =
                    PickLocation.update Configs.pickLocation game msg page

                model_ =
                    setPage (PickLocationModel page_) model
            in
                ( model_, cmd_, dispatch )

        _ ->
            Update.fromModel model



-- request handlers


updateRequest : Game.Model -> Maybe Response -> Model -> UpdateResponse
updateRequest game response model =
    case response of
        _ ->
            Update.fromModel model



-- event handlers


handleJoinedAccount : Value -> Model -> UpdateResponse
handleJoinedAccount value model =
    case Decode.decodeValue Decoders.Account.setupPages value of
        Ok pages ->
            let
                model_ =
                    model
                        |> doneLoading
                        |> setPages pages

                dispatch =
                    if hasPages model_ then
                        Dispatch.core Core.Play
                    else
                        Dispatch.none
            in
                ( model_, Cmd.none, dispatch )

        Err reason ->
            let
                dispatch =
                    Dispatch.politeCrash "ERR_PORRA_RENATO"
                        ("Can't decide setup pages: " ++ reason)
            in
                ( model, Cmd.none, dispatch )



-- helpers


locationPickerCmd : Model -> Cmd Msg
locationPickerCmd model =
    case model.page of
        Just (PickLocationModel _) ->
            Cmd.batch
                [ Map.mapInit mapId
                , geoLocReq geoInstance
                ]

        _ ->
            Cmd.none
