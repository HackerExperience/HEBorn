module OS.SessionManager.Models
    exposing
        ( Model
        , SessionManagers
        , WindowRef
        , initialModel
        , get
        , insert
        , refresh
        , remove
        , getWindow
        , setWindow
        , getWindowID
        , windows
        )

import Dict exposing (Dict)
import Maybe exposing (Maybe(..))
import Random.Pcg as Random
import OS.SessionManager.WindowManager.Models as WindowManager
    exposing
        ( WindowID
        , Window
        )


-- NOTE: some changes are needed to allow pinned windows, mostly with how
-- the windows list is built; we may or not need a type that looks like this:


type alias ServerID =
    String


type alias WindowRef =
    ( ServerID, WindowID )


type alias SessionManagers =
    Dict ServerID WindowManager.Model


type alias Model =
    { sessions : SessionManagers
    , seed : Random.Seed
    }


initialModel : Model
initialModel =
    -- TODO: fetch this from game and stop keeping the active one
    { sessions = Dict.empty
    , seed = initialSeed
    }


get : ServerID -> Model -> Maybe WindowManager.Model
get session { sessions } =
    Dict.get session sessions


insert : ServerID -> Model -> Model
insert id ({ sessions, seed } as model) =
    if not (Dict.member id sessions) then
        let
            sessions_ =
                Dict.insert
                    id
                    (WindowManager.initialModel seed)
                    sessions

            seed_ =
                newSeed (Dict.size sessions_)
        in
            { model | sessions = sessions_, seed = seed_ }
    else
        model


refresh : ServerID -> WindowManager.Model -> Model -> Model
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


remove : ServerID -> Model -> Model
remove id ({ sessions } as model) =
    let
        sessions_ =
            Dict.remove id sessions
    in
        { model | sessions = sessions_ }


getWindowID : WindowRef -> WindowID
getWindowID ( _, id ) =
    id


getWindow : WindowRef -> Model -> Maybe Window
getWindow ( session, id ) { sessions } =
    case Dict.get session sessions of
        Just wm ->
            WindowManager.getWindow id wm

        Nothing ->
            Nothing


setWindow : WindowRef -> Window -> Model -> Model
setWindow ( session, id ) window ({ sessions } as model) =
    case Dict.get session sessions of
        Just wm ->
            let
                wm_ =
                    WindowManager.setWindow id window wm

                sessions_ =
                    Dict.insert session wm_ sessions
            in
                { model | sessions = sessions_ }

        Nothing ->
            model



-- TODO: evaluate if this is needed


windows : String -> Model -> List ( ServerID, WindowID )
windows id model =
    -- TODO: update this function to support pinning windows
    case get id model of
        Just wm ->
            wm.windows
                |> Dict.keys
                |> List.map (\windowID -> ( id, windowID ))

        _ ->
            []



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
