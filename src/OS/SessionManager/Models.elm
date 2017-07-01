module OS.SessionManager.Models
    exposing
        ( Model
        , SessionManagers
        , WindowRef
        , initialModel
        , insert
        , current
        , switch
        , refresh
        , remove
        , getWindow
        , setWindow
        , getWindowID
        , getWindowManager
        , windows
        , unsafeGetActive
        )

import Dict exposing (Dict)
import Maybe exposing (Maybe(..))
import Game.Models as Game
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
    { active : Maybe ServerID
    , sessions : SessionManagers
    , seed : Random.Seed
    }


initialModel : Game.Model -> Model
initialModel game =
    -- TODO: fetch this from game and stop keeping the active one
    empty
        |> insert "gateway0"


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
            autoActivate id
                { model | sessions = sessions_, seed = seed_ }
    else
        autoActivate id model


current : Model -> Maybe WindowManager.Model
current { active, sessions } =
    case active of
        Just id ->
            Dict.get id sessions

        Nothing ->
            Nothing


switch : ServerID -> Model -> Model
switch id ({ sessions } as model) =
    if Dict.member id sessions then
        { model | active = Just id }
    else
        model


refresh : WindowManager.Model -> Model -> Model
refresh wm ({ sessions, active } as model) =
    case active of
        Just id ->
            let
                sessions_ =
                    Dict.insert id wm sessions
            in
                { model | sessions = sessions_ }

        Nothing ->
            model


remove : ServerID -> Model -> Model
remove id ({ sessions, active } as model) =
    let
        activeID =
            case active of
                Just id ->
                    id

                Nothing ->
                    ""

        sessions_ =
            Dict.remove id sessions

        active_ =
            if id == activeID then
                sessions_
                    |> Dict.keys
                    |> List.head
            else
                active
    in
        case active_ of
            Just _ ->
                { model | sessions = sessions_, active = active_ }

            Nothing ->
                -- never remove the last server
                model


getWindowID : WindowRef -> WindowID
getWindowID ( _, id ) =
    id


getWindowManager : ServerID -> Model -> Maybe WindowManager.Model
getWindowManager session { sessions } =
    Dict.get session sessions


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


windows : Model -> List ( ServerID, WindowID )
windows ({ active } as model) =
    -- TODO: update this function to support pinning windows
    case ( active, current model ) of
        ( Just wmID, Just wm ) ->
            wm.windows
                |> Dict.keys
                |> List.map (\windowID -> ( wmID, windowID ))

        _ ->
            []


unsafeGetActive : Model -> String
unsafeGetActive { active } =
    case active of
        Just id ->
            id

        Nothing ->
            ""



-- internals


empty : Model
empty =
    { active = Nothing
    , sessions = emptySessionManagers
    , seed = initialSeed
    }


emptySessionManagers : SessionManagers
emptySessionManagers =
    Dict.empty


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


autoActivate : ServerID -> Model -> Model
autoActivate id ({ active } as model) =
    case active of
        Nothing ->
            { model | active = Just id }

        Just _ ->
            model
