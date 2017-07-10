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
        , refresh
        , remove
        )

import Uuid
import Dict exposing (Dict)
import Maybe exposing (Maybe(..))
import Random.Pcg as Random
import Apps.Apps as Apps
import OS.SessionManager.WindowManager.Models as WindowManager


type alias Model =
    { sessions : Sessions
    , seed : Random.Seed
    }


type alias Sessions =
    Dict ID WindowManager.Model


type alias ID =
    String


type alias WindowRef =
    ( ID, WindowManager.ID )


initialModel : Model
initialModel =
    -- TODO: fetch this from game and stop keeping the active one
    { sessions = Dict.empty
    , seed = initialSeed
    }


get : ID -> Model -> Maybe WindowManager.Model
get session { sessions } =
    Dict.get session sessions


insert : ID -> Model -> Model
insert id ({ sessions, seed } as model) =
    if not (Dict.member id sessions) then
        let
            sessions_ =
                Dict.insert
                    id
                    WindowManager.initialModel
                    sessions

            seed_ =
                newSeed (Dict.size sessions_)
        in
            { model | sessions = sessions_ }
    else
        model


openApp : ID -> Apps.App -> Model -> Model
openApp id app ({ sessions } as model0) =
    case Dict.get id sessions of
        Just wm ->
            let
                ( uuid, model ) =
                    getUID model0

                wm_ =
                    WindowManager.insert uuid app wm

                sessions_ =
                    Dict.insert id wm_ sessions

                model_ =
                    { model | sessions = sessions_ }
            in
                model_

        Nothing ->
            model0


getUID : Model -> ( String, Model )
getUID ({ sessions, seed } as model) =
    let
        ( uuid, seed_ ) =
            Random.step Uuid.uuidGenerator seed

        model_ =
            { model | seed = seed_ }

        uuid_ =
            Uuid.toString uuid
    in
        ( uuid_, model_ )


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



-- internals


seed : Int
seed =
    -- a magic number from some other game
    844121764423


newSeed : Int -> Random.Seed
newSeed a =
    Random.initialSeed (seed + a)


initialSeed : Random.Seed
initialSeed =
    newSeed 0
