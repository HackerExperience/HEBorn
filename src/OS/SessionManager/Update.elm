module OS.SessionManager.Update exposing (update)

import OS.SessionManager.Models exposing (..)
import OS.SessionManager.Messages exposing (..)
import OS.SessionManager.Dock.Update as Dock
import Core.Messages exposing (CoreMsg)
import OS.SessionManager.WindowManager.Update as WindowManager
import OS.SessionManager.WindowManager.Messages as WindowManager
import Game.Models exposing (GameModel)


update :
    Msg
    -> GameModel
    -> Model
    -> ( Model, Cmd Msg, List CoreMsg )
update msg game model =
    case msg of
        WindowManagerMsg msg ->
            model
                |> windowManager msg game
                |> defaultNone model

        DockMsg msg ->
            ( Dock.update msg model, Cmd.none, [] )



-- internals


windowManager :
    WindowManager.Msg
    -> GameModel
    -> Model
    -> Maybe ( Model, Cmd Msg, List CoreMsg )
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
    -> Maybe ( Model, Cmd msg, List b )
    -> ( Model, Cmd msg, List b )
defaultNone model =
    Maybe.withDefault ( model, Cmd.none, [] )


map :
    (model -> Model)
    -> (msg -> Msg)
    -> ( model, Cmd msg, List CoreMsg )
    -> ( Model, Cmd Msg, List CoreMsg )
map mapModel mapMsg ( model, msg, cmds ) =
    ( mapModel model, Cmd.map mapMsg msg, cmds )
