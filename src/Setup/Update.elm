module Setup.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.React as React exposing (React)
import Utils.Ports.Map as Map
import Utils.Ports.Geolocation exposing (geoLocReq, geoRevReq, decodeLabel)
import Decoders.Client
import Core.Error as Error
import Game.Account.Models as Account
import Game.Servers.Shared as Servers
import Setup.Pages.PickLocation.Update as PickLocation
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Update as Mainframe
import Setup.Pages.Mainframe.Messages as Mainframe
import Setup.Requests.Setup as Setup
import Setup.Requests.SetServer as SetServer
import Setup.Settings as Settings exposing (Settings)
import Setup.Config exposing (..)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)
import Setup.Requests exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


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
                handleJoinedAccount config value model
            else
                ( model, React.none )

        HandleJoinedServer cid ->
            if isLoading model then
                handleJoinedServer config cid model
            else
                ( model, React.none )

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
                ( model_, react ) =
                    setRequest config model
            in
                ( model_, react )
        else
            ( model, React.none )


onPreviousPage : Config msg -> Model -> UpdateResponse msg
onPreviousPage { toMsg } model =
    let
        model_ =
            previousPage model

        react =
            locationPickerCmd model_
                |> Cmd.map toMsg
                |> React.cmd
    in
        ( model_, react )



-- child message handlers


onMainframeMsg : Config msg -> Mainframe.Msg -> Model -> UpdateResponse msg
onMainframeMsg config msg model =
    case model.page of
        Just (MainframeModel page) ->
            let
                ( page_, react ) =
                    Mainframe.update (mainframeConfig config) msg page

                model_ =
                    setPage (MainframeModel page_) model
            in
                ( model_, react )

        _ ->
            ( model, React.none )


onPickLocationMsg : Config msg -> PickLocation.Msg -> Model -> UpdateResponse msg
onPickLocationMsg config msg model =
    case model.page of
        Just (PickLocationModel page) ->
            let
                ( page_, react ) =
                    PickLocation.update (pickLocationConfig config) msg page

                model_ =
                    setPage (PickLocationModel page_) model
            in
                ( model_, react )

        _ ->
            ( model, React.none )



-- request handlers


updateRequest : Config msg -> Maybe Response -> Model -> UpdateResponse msg
updateRequest config response model =
    case response of
        Just (SetServer problems) ->
            onGenericSet config problems model

        Just (Setup status) ->
            onSetup config status model

        Nothing ->
            ( model, React.none )


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
                |> React.cmd
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
                    |> flip (,) React.none


onSetup : Config msg -> Setup.Response -> Model -> UpdateResponse msg
onSetup config status model =
    case status of
        Setup.Okay ->
            ( model, React.msg config.onPlay )

        Setup.Error ->
            -- TODO: decide what to do
            ( model, React.none )



-- event handlers


handleJoinedAccount : Config msg -> Value -> Model -> UpdateResponse msg
handleJoinedAccount config value model =
    case Decode.decodeValue Decoders.Client.setupPages value of
        Ok pages ->
            ( setPages pages model
            , React.none
            )

        Err reason ->
            let
                react =
                    ("Can't decide setup pages: " ++ reason)
                        |> Error.porra
                        |> config.onError
                        |> React.msg
            in
                ( model, react )


handleJoinedServer : Config msg -> Servers.CId -> Model -> UpdateResponse msg
handleJoinedServer config cid model =
    let
        react =
            if hasPages model then
                React.none
            else
                React.msg config.onPlay
    in
        if config.mainframe == cid then
            ( doneLoading model, react )
        else
            ( model, React.none )



-- helpers


locationPickerCmd : Model -> Cmd msg
locationPickerCmd model =
    case model.page of
        Just (PickLocationModel _) ->
            Cmd.batch
                [ Map.mapInit mapId
                , geoLocReq geoInstance
                ]

        _ ->
            Cmd.none


setRequest : Config msg -> Model -> UpdateResponse msg
setRequest config model =
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
            config.mainframe

        request ( type_, settings ) =
            case type_ of
                Settings.ServerTopic ->
                    Cmd.map config.toMsg <|
                        SetServer.request settings cid config

                Settings.AccountTopic ->
                    Cmd.none

        react =
            settings
                |> List.map request
                |> Cmd.batch
                |> React.cmd
    in
        ( model_, react )
