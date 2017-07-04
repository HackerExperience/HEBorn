module OS.SessionManager.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.WindowManager.Update as WindowManager
import OS.SessionManager.WindowManager.Messages as WindowManager
import Game.Data as GameData
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
                model_
                    |> windowManager data msg
                    |> defaultNone model

            DockMsg msg ->
                ( Dock.update data msg model_, Cmd.none, Dispatch.none )



-- internals


windowManager :
    GameData.Data
    -> WindowManager.Msg
    -> Model
    -> Maybe ( Model, Cmd Msg, Dispatch )
windowManager data msg model =
    case get data.id model of
        Just wm ->
            wm
                |> WindowManager.update data msg
                |> map (flip (refresh data.id) model)
                    WindowManagerMsg
                |> Just

        _ ->
            Nothing


ensureSession : GameData.Data -> Model -> Model
ensureSession data model =
    case get data.id model of
        Just _ ->
            model

        Nothing ->
            insert data.id model


defaultNone :
    Model
    -> Maybe ( Model, Cmd msg, Dispatch )
    -> ( Model, Cmd msg, Dispatch )
defaultNone model =
    Maybe.withDefault ( model, Cmd.none, Dispatch.none )


map :
    (model -> Model)
    -> (msg -> Msg)
    -> ( model, Cmd msg, Dispatch )
    -> ( Model, Cmd Msg, Dispatch )
map mapModel mapMsg ( model, msg, cmds ) =
    ( mapModel model, Cmd.map mapMsg msg, cmds )
