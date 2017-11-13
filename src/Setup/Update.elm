module Setup.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.Update as Update
import Core.Messages as Core
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Core as Core
import Core.Error as Error
import Game.Models as Game
import Game.Account.Models as Account
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)
import Setup.Requests exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.Configs as Configs
import Setup.Pages.PickLocation.Update as PickLocation
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Update as Mainframe
import Setup.Pages.Mainframe.Messages as Mainframe
import Setup.Requests.Setup as Setup
import Setup.Requests.SetServer as SetServer
import Decoders.Client


type alias UpdateResponse =
    ( Model, Cmd Msg, Dispatch )


update : Game.Model -> Msg -> Model -> UpdateResponse
update game msg model =
    case msg of
        NextPage settings ->
            onNextPage game settings model

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
--    Dispatch.core Core.Play


onNextPage : Game.Model -> List Settings -> Model -> UpdateResponse
onNextPage game settings model0 =
    let
        model =
            nextPage settings model0
    in
        if doneSetup model then
            let
                ( model_, cmd ) =
                    setRequest game model
            in
                ( model_, Cmd.none, Dispatch.none )
        else
            ( model, Cmd.none, Dispatch.none )


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
        Just (SetServer problems) ->
            onGenericSet game problems model

        Just (Setup status) ->
            onSetup game status model

        Nothing ->
            Update.fromModel model


onGenericSet : Game.Model -> List Settings -> Model -> UpdateResponse
onGenericSet game list model =
    let
        model_ =
            setTopicsDone Settings.ServerTopic True model
    in
        if List.isEmpty list && noTopicsRemaining model_ then
            let
                id =
                    game
                        |> Game.getAccount
                        |> Account.getId
            in
                ( model_
                , Setup.request (List.map Tuple.first model.done) id game
                , Dispatch.none
                )
        else
            let
                noErrors =
                    flip List.member list >> not

                keepBadPages ( model, settings ) =
                    if List.all noErrors settings then
                        Nothing
                    else
                        Just <| pageModelToString model
            in
                model_
                    |> setBadPages (List.filterMap keepBadPages model.done)
                    |> undoPages
                    |> Update.fromModel


onSetup : Game.Model -> Setup.Response -> Model -> UpdateResponse
onSetup game status model =
    case status of
        Setup.Okay ->
            ( model, Cmd.none, Dispatch.core Core.Play )

        Setup.Error ->
            -- TODO: decide what to do
            Update.fromModel model



-- event handlers


handleJoinedAccount : Value -> Model -> UpdateResponse
handleJoinedAccount value model =
    case Decode.decodeValue Decoders.Client.setupPages value of
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
                    ("Can't decide setup pages: " ++ reason)
                        |> Error.porra
                        |> Core.Crash
                        |> Dispatch.core
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


setRequest : Game.Model -> Model -> ( Model, Cmd Msg )
setRequest game model =
    -- this could be improved
    let
        mainframe =
            game
                |> Game.getAccount
                |> Account.getMainframe
    in
        case mainframe of
            Just mainframe ->
                let
                    settings =
                        model
                            |> getDone
                            |> List.concatMap Tuple.second
                            |> Settings.groupSettings

                    model_ =
                        List.foldl (Tuple.first >> flip setTopicsDone False)
                            model
                            settings

                    cid =
                        mainframe

                    request ( type_, settings ) =
                        case type_ of
                            Settings.ServerTopic ->
                                SetServer.request settings cid game

                            Settings.AccountTopic ->
                                Cmd.none

                    cmd =
                        settings
                            |> List.map request
                            |> Cmd.batch
                in
                    ( model_, cmd )

            Nothing ->
                ( model, Cmd.none )
