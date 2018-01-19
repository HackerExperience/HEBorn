module Setup.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.Update as Update
import Core.Dispatch as Dispatch exposing (Dispatch)
import Core.Dispatch.Core as Core
import Core.Error as Error
import Game.Account.Models as Account
import Game.Servers.Shared as Servers
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Setup.Config exposing (..)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)
import Setup.Requests exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.PickLocation.Update as PickLocation
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Update as Mainframe
import Setup.Pages.Mainframe.Messages as Mainframe
import Setup.Requests.Setup as Setup
import Setup.Requests.SetServer as SetServer
import Decoders.Client


type alias UpdateResponse msg =
    ( Model, Cmd msg, Dispatch )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        NextPage settings ->
            onNextPage config settings model

        PreviousPage ->
            onPreviousPage config model

        MainframeMsg msg ->
            onMainframeMsg config msg model

        PickLocationMsg msg ->
            onPickLocationMsg config msg model

        HandleJoinedAccount value ->
            if isLoading model then
                handleJoinedAccount value model
            else
                Update.fromModel model

        HandleJoinedServer cid ->
            if isLoading model then
                handleJoinedServer config cid model
            else
                Update.fromModel model

        Request data ->
            updateRequest config (receive data) model



-- message handlers


onNextPage : Config msg -> List Settings -> Model -> UpdateResponse msg
onNextPage config settings model0 =
    let
        model =
            nextPage settings model0
    in
        if doneSetup model then
            let
                ( model_, cmd ) =
                    setRequest config model

                cmd_ =
                    Cmd.map config.toMsg cmd
            in
                ( model_, cmd_, Dispatch.none )
        else
            ( model, Cmd.none, Dispatch.none )


onPreviousPage : Config msg -> Model -> UpdateResponse msg
onPreviousPage { toMsg } model =
    let
        model_ =
            previousPage model

        cmd =
            locationPickerCmd model_
                |> Cmd.map toMsg
    in
        ( model_, cmd, Dispatch.none )



-- child message handlers


onMainframeMsg : Config msg -> Mainframe.Msg -> Model -> UpdateResponse msg
onMainframeMsg config msg model =
    case model.page of
        Just (MainframeModel page) ->
            let
                ( page_, cmd_, dispatch ) =
                    Mainframe.update (mainframeConfig config) msg page

                model_ =
                    setPage (MainframeModel page_) model
            in
                ( model_, cmd_, dispatch )

        _ ->
            Update.fromModel model


onPickLocationMsg : Config msg -> PickLocation.Msg -> Model -> UpdateResponse msg
onPickLocationMsg config msg model =
    case model.page of
        Just (PickLocationModel page) ->
            let
                ( page_, cmd_, dispatch ) =
                    PickLocation.update (pickLocationConfig config) msg page

                model_ =
                    setPage (PickLocationModel page_) model
            in
                ( model_, cmd_, dispatch )

        _ ->
            Update.fromModel model



-- request handlers


updateRequest : Config msg -> Maybe Response -> Model -> UpdateResponse msg
updateRequest config response model =
    case response of
        Just (SetServer problems) ->
            onGenericSet config problems model

        Just (Setup status) ->
            onSetup config status model

        Nothing ->
            Update.fromModel model


onGenericSet : Config msg -> List Settings -> Model -> UpdateResponse msg
onGenericSet ({ accountId } as config) list model =
    let
        model_ =
            setTopicsDone Settings.ServerTopic True model
    in
        if List.isEmpty list && noTopicsRemaining model_ then
            ( model_
            , config
                |> Setup.request (List.map Tuple.first model.done) accountId
                |> Cmd.map config.toMsg
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


onSetup : Config msg -> Setup.Response -> Model -> UpdateResponse msg
onSetup _ status model =
    case status of
        Setup.Okay ->
            ( model, Cmd.none, Dispatch.core Core.Play )

        Setup.Error ->
            -- TODO: decide what to do
            Update.fromModel model



-- event handlers


handleJoinedAccount : Value -> Model -> UpdateResponse msg
handleJoinedAccount value model =
    case Decode.decodeValue Decoders.Client.setupPages value of
        Ok pages ->
            ( setPages pages model
            , Cmd.none
            , Dispatch.none
            )

        Err reason ->
            let
                dispatch =
                    ("Can't decide setup pages: " ++ reason)
                        |> Error.porra
                        |> Core.Crash
                        |> Dispatch.core
            in
                ( model, Cmd.none, dispatch )


handleJoinedServer : Config msg -> Servers.CId -> Model -> UpdateResponse msg
handleJoinedServer { mainframe } cid model =
    let
        dispatch =
            if hasPages model then
                Dispatch.none
            else
                Dispatch.core Core.Play
    in
        case mainframe of
            Just mainframe ->
                if mainframe == cid then
                    ( doneLoading model
                    , Cmd.none
                    , dispatch
                    )
                else
                    Update.fromModel model

            Nothing ->
                Update.fromModel model



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


setRequest : Config msg -> Model -> ( Model, Cmd Msg )
setRequest ({ mainframe } as config) model =
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
                            SetServer.request settings cid config

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
