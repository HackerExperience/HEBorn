module OS.SessionManager.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Dock.Update as Dock
import OS.SessionManager.WindowManager.Update as WindowManager
import OS.SessionManager.WindowManager.Messages as WindowManager
import Game.Data as Game
import Game.Models as Game
import Core.Dispatch as Dispatch exposing (Dispatch)


update :
    Game.Model
    -> Msg
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
update game msg model =
    case msg of
        WindowManagerMsg msg ->
            model
                |> windowManager game msg
                |> defaultNone model

        DockMsg msg ->
            ( Dock.update msg model, Cmd.none, Dispatch.none )



-- internals


windowManager :
    Game.Model
    -> WindowManager.Msg
    -> Model
    -> Maybe ( Model, Cmd Msg, Dispatch )
windowManager game msg model =
    case ( current model, Game.toContext game ) of
        ( Just wm, Just game ) ->
            wm
                |> WindowManager.update game msg
                |> map (flip refresh model) WindowManagerMsg
                |> Just

        _ ->
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
