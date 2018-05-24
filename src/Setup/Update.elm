module Setup.Update exposing (update)

import Json.Decode as Decode exposing (Value)
import Utils.React as React exposing (React)
import Utils.Ports.Leaflet as Leaflet
import Utils.Ports.Geolocation as Geolocation
import Decoders.Client
import Core.Error as Error
import Game.Servers.Shared as Servers
import Setup.Pages.PickLocation.Update as PickLocation
import Setup.Pages.PickLocation.Messages as PickLocation
import Setup.Pages.Mainframe.Update as Mainframe
import Setup.Pages.Mainframe.Messages as Mainframe
import Setup.Requests.Setup as SetupRequest exposing (setupRequest)
import Setup.Requests.SetServer as SetServerRequest exposing (setServerRequest)
import Setup.Settings as Settings exposing (Settings)
import Setup.Config exposing (..)
import Setup.Models exposing (..)
import Setup.Messages exposing (..)


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

        SetServerRequest problems ->
            onGenericSet config problems model

        SetupRequest status ->
            onSetup config status model



-- message handlers


onNextPage : Config msg -> List Settings -> Model -> UpdateResponse msg
onNextPage config settings model0 =
    let
        model =
            nextPage settings model0

        cmd =
            case model.page of
                Just (PickLocationModel _) ->
                    Cmd.map config.toMsg <| locationPickerCmd model

                _ ->
                    Cmd.none
    in
        if doneSetup model then
            model
                |> setRequest config
                |> Tuple.mapSecond (React.addCmd cmd)
        else
            ( model, React.cmd cmd )


onPreviousPage : Config msg -> Model -> UpdateResponse msg
onPreviousPage { toMsg } model =
    let
        model_ =
            previousPage model

        react =
            case model.page of
                Just (PickLocationModel _) ->
                    locationPickerCmd model_
                        |> Cmd.map toMsg
                        |> React.cmd

                _ ->
                    React.none
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


onGenericSet :
    Config msg
    -> SetServerRequest.Data
    -> Model
    -> UpdateResponse msg
onGenericSet ({ accountId } as config) list model =
    let
        model_ =
            setTopicsDone Settings.ServerTopic True model
    in
        if List.isEmpty list && noTopicsRemaining model_ then
            ( model_
            , config
                |> setupRequest (List.map Tuple.first model.done) accountId
                |> Cmd.map (SetupRequest >> config.toMsg)
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


onSetup : Config msg -> SetupRequest.Data -> Model -> UpdateResponse msg
onSetup config status model =
    case status of
        Ok () ->
            ( model, React.msg config.onPlay )

        Err () ->
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
        if config.mainframe == (Just cid) then
            ( doneLoading model, react )
        else
            ( model, React.none )



-- helpers


locationPickerCmd : Model -> Cmd msg
locationPickerCmd model =
    case model.page of
        Just (PickLocationModel _) ->
            Cmd.batch
                [ Leaflet.init mapId
                , Geolocation.getCoordinates geoInstance
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
                    case config.mainframe of
                        Just cid ->
                            config
                                |> setServerRequest settings cid
                                |> Cmd.map (SetServerRequest >> config.toMsg)

                        Nothing ->
                            Cmd.none

                Settings.AccountTopic ->
                    Cmd.none

        react =
            settings
                |> List.map request
                |> Cmd.batch
                |> React.cmd
    in
        ( model_, react )
