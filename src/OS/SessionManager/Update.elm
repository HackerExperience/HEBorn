module OS.SessionManager.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.WindowManager.Update as WindowManager
import OS.SessionManager.WindowManager.Messages as WindowManager
import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Msg
    -> Game.Model
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update msg game model =
    case msg of
        WindowManagerMsg msg ->
            model
                |> windowManager msg game
                |> defaultNone model

        DockMsg msg ->
            ( Dock.update msg model, Cmd.none, Dispatch.none )



-- internals


windowManager :
    WindowManager.Msg
    -> Game.Model
    -> Model
    -> Maybe ( Model, Cmd Msg, Dispatch )
windowManager msg game model =
    case (current model) of
        Just wm ->
            wm
                |> WindowManager.update msg game
                |> map (flip refresh model) WindowManagerMsg
                |> Just

        Nothing ->
            Nothing


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
