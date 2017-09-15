module OS.SessionManager.Models exposing (..)

import Dict exposing (Dict)
import Random.Pcg as Random
import Utils.Model.RandomUuid as RandomUuid
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
                    (WindowManager.initialModel id)
                    sessions
        in
            { model | sessions = sessions_ }
    else
        model


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
