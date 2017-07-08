module OS.SessionManager.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
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
        model_ =
            ensureSession data model
    in
        case msg of
            WindowManagerMsg msg ->
                windowManager data msg model_

            DockMsg msg ->
                ( Dock.update data msg model_, Cmd.none, Dispatch.none )



-- internals


windowManager :
    GameData.Data
    -> WM.Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
windowManager data msg model =
    let
        wm =
            model
                |> get data.id
                |> Maybe.withDefault WM.initialModel

        ( wm_, cmd, dispatch ) =
            WM.update data msg wm

        model_ =
            refresh data.id wm_ model

        cmd_ =
            Cmd.map WindowManagerMsg cmd
    in
        ( model_, cmd_, dispatch )


ensureSession : GameData.Data -> Model -> Model
ensureSession data model =
    case get data.id model of
        Just _ ->
            model

        Nothing ->
            insert data.id model
