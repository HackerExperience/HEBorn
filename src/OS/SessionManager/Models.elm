module OS.SessionManager.Models exposing (..)

import Dict exposing (Dict)
import Random.Pcg as Random
import Utils.Model.RandomUuid as RandomUuid
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.Types exposing (..)
import Game.Meta.Types exposing (Context(..))


type alias Model =
    RandomUuid.Model { sessions : Sessions }


type alias Sessions =
    Dict ID WM.Model


type alias WindowRef =
    ( ID, WM.ID )


initialModel : Model
initialModel =
    -- TODO: fetch this from game and stop keeping the active one
    { randomUuidSeed = Random.initialSeed 844121764423
    , sessions = Dict.empty
    }


get : ID -> Model -> Maybe WM.Model
get session { sessions } =
    Dict.get session sessions


insert : ID -> Model -> Model
insert id ({ sessions } as model) =
    if not (Dict.member id sessions) then
        let
            sessions_ =
                Dict.insert
                    id
                    (WM.initialModel id)
                    sessions
        in
            { model | sessions = sessions_ }
    else
        model


filterSessions : (ID -> WM.Model -> Bool) -> Model -> Sessions
filterSessions func { sessions } =
    Dict.filter func sessions


getUID : Model -> ( Model, String )
getUID =
    RandomUuid.newUuid


refresh : ID -> WM.Model -> Model -> Model
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


getWindowID : WindowRef -> WM.ID
getWindowID ( _, id ) =
    id
