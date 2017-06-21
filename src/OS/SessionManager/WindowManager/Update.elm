module OS.SessionManager.WindowManager.Update exposing (..)

import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Core.Messages as Core
import Game.Models as Game
import Apps.Update as Apps
import Apps.Messages as Apps
import OS.SessionManager.WindowManager.Models
    exposing
        ( Model
        , WindowID
        , openWindow
        , openOrRestoreWindow
        , closeWindow
        , closeAppWindows
        , restoreWindow
        , minimizeWindow
        , minimizeAppWindows
        , toggleWindowMaximization
        , unfocusWindow
        , focusWindow
        , updateWindowPosition
        , getAppModel
        , getWindow
        , updateAppModel
        , toggleWindowContext
        , startDragging
        , stopDragging
        )
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))


update : Msg -> Game.Model -> Model -> ( Model, Cmd Msg, List Core.Msg )
update msg game model =
    case msg of
        OnDragBy delta ->
            model
                |> updateWindowPosition delta
                |> wrapEmpty

        DragMsg dragMsg ->
            let
                ( model_, cmd ) =
                    Draggable.update dragConfig dragMsg model
            in
                ( model_, cmd, [] )

        StartDragging windowID ->
            model
                |> startDragging windowID
                |> wrapEmpty

        StopDragging ->
            model
                |> stopDragging
                |> wrapEmpty

        UpdateFocusTo maybeWindowID ->
            case maybeWindowID of
                Just windowID ->
                    model
                        |> focusWindow windowID
                        |> wrapEmpty

                Nothing ->
                    model
                        |> unfocusWindow
                        |> wrapEmpty

        Close windowID ->
            model
                |> closeWindow windowID
                |> unfocusWindow
                |> wrapEmpty

        ToggleMaximize windowID ->
            model
                |> toggleWindowMaximization windowID
                |> unfocusWindow
                |> focusWindow windowID
                |> wrapEmpty

        Minimize windowID ->
            model
                |> minimizeWindow windowID
                |> unfocusWindow
                |> wrapEmpty

        SwitchContext windowID ->
            model
                |> toggleWindowContext windowID
                |> wrapEmpty

        WindowMsg windowID msg ->
            let
                ( model_, cmd, msgs ) =
                    updateApp game windowID msg model

                cmd_ =
                    Cmd.map (WindowMsg windowID) cmd
            in
                ( model_, cmd_, msgs )



-- internals


updateApp :
    Game.Model
    -> WindowID
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd Apps.Msg, List Core.Msg )
updateApp game windowID msg model =
    case getWindow windowID model of
        Just window ->
            let
                ( appModel, cmd, msgs ) =
                    Apps.update msg game (getAppModel window)

                model_ =
                    (updateAppModel windowID appModel model)
            in
                ( model_, cmd, msgs )

        Nothing ->
            ( model, Cmd.none, [] )


wrapEmpty : Model -> ( Model, Cmd Msg, List Core.Msg )
wrapEmpty model =
    ( model, Cmd.none, [] )


dragConfig : Draggable.Config WindowID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
