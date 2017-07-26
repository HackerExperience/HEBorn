module OS.SessionManager.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Helpers exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.WindowManager.Update as WM
import OS.SessionManager.WindowManager.Models as WM
import OS.SessionManager.WindowManager.Messages as WM
import Game.Data as GameData
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    GameData.Data
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update data msg model =
    let
        id =
            toSessionID data

        model_ =
            ensureSession id model
    in
        case msg of
            WindowManagerMsg msg ->
                windowManager data id msg model_

            DockMsg msg ->
                Dock.update data msg model_



-- internals


windowManager :
    GameData.Data
    -> ID
    -> WM.Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
windowManager data id msg model =
    let
        wm =
            model
                |> get id
                |> Maybe.withDefault WM.initialModel

        ( wm_, cmd, dispatch ) =
            WM.update data msg wm

        model_ =
            refresh id wm_ model

        cmd_ =
            Cmd.map WindowManagerMsg cmd
    in
        ( model_, cmd_, dispatch )


ensureSession : ID -> Model -> Model
ensureSession id model =
    case get id model of
        Just _ ->
            model

        Nothing ->
            insert id model
