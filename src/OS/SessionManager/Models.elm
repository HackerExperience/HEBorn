module OS.SessionManager.Models
    exposing
        ( Model
        , Sessions
        , ID
        , WindowRef
        , initialModel
        , get
        , insert
        , openApp
        , openOrRestoreApp
        , refresh
        , remove
        )

import Dict exposing (Dict)
import Random.Pcg as Random
import Utils.Model.RandomUuid as RandomUuid
import Apps.Apps as Apps
import Game.Network.Types exposing (NIP)
import OS.SessionManager.WindowManager.Models as WindowManager


type alias Model =
    RandomUuid.Model { sessions : Sessions }


type alias Sessions =
    Dict ID WindowManager.Model


type alias ID =
    String


type alias WindowRef =
    ( ID, WindowManager.ID )


initialModel : Model
initialModel =
    -- TODO: fetch this from game and stop keeping the active one
    { randomUuidSeed = Random.initialSeed 844121764423
    , sessions = Dict.empty
    }


get : ID -> Model -> Maybe WindowManager.Model
get session { sessions } =
    Dict.get session sessions


insert : ID -> Model -> Model
insert id ({ sessions } as model) =
    if not (Dict.member id sessions) then
        let
            sessions_ =
                Dict.insert
                    id
                    WindowManager.initialModel
                    sessions
        in
            { model | sessions = sessions_ }
    else
        model


openApp : ID -> Maybe NIP -> Apps.App -> Model -> ( Model, Maybe String )
openApp id nip app ({ sessions } as model0) =
    case Dict.get id sessions of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, wId ) =
                    WindowManager.insert uuid nip app wm

                sessions_ =
                    Dict.insert id wm_ sessions

                model_ =
                    { model | sessions = sessions_ }
            in
                ( model_, wId )

        Nothing ->
            ( model0, Nothing )


openOrRestoreApp : ID -> Maybe NIP -> Apps.App -> Model -> ( Model, Maybe String )
openOrRestoreApp id nip app ({ sessions } as model0) =
    case Dict.get id sessions of
        Just wm ->
            let
                ( model, uuid ) =
                    getUID model0

                ( wm_, wId ) =
                    WindowManager.resert uuid nip app wm

                sessions_ =
                    Dict.insert id wm_ sessions

                model_ =
                    { model | sessions = sessions_ }
            in
                ( model_, wId )

        Nothing ->
            ( model0, Nothing )


getUID : Model -> ( Model, String )
getUID =
    RandomUuid.newUuid


refresh : ID -> WindowManager.Model -> Model -> Model
refresh id wm ({ sessions } as model) =
    case Dict.get id sessions of
        Just _ ->
            let
                sessions_ =
                    Dict.insert id wm sessions
            in
                { model | sessions = sessions_ }

        Nothing ->
            model


remove : ID -> Model -> Model
remove id ({ sessions } as model) =
    let
        sessions_ =
            Dict.remove id sessions
    in
        { model | sessions = sessions_ }


getWindowID : WindowRef -> WindowManager.ID
getWindowID ( _, id ) =
    id
