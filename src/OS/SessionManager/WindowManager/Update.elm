module OS.SessionManager.WindowManager.Update exposing (..)

import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
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
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Game.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update game msg model =
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
                ( model_, cmd, Dispatch.none )

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
                ( model_, cmd, dispatch ) =
                    updateApp game windowID msg model

                cmd_ =
                    Cmd.map (WindowMsg windowID) cmd
            in
                ( model_, cmd_, dispatch )



-- internals


updateApp :
    Game.Model
    -> WindowID
    -> Apps.Msg
    -> Model
    -> ( Model, Cmd Apps.Msg, Dispatch )
updateApp game windowID msg model =
    case getWindow windowID model of
        Just window ->
            let
                ( appModel, cmd, dispatch ) =
                    Apps.update game msg (getAppModel window)

                model_ =
                    (updateAppModel windowID appModel model)
            in
                ( model_, cmd, dispatch )

        Nothing ->
            ( model, Cmd.none, Dispatch.none )


wrapEmpty : Model -> ( Model, Cmd Msg, Dispatch )
wrapEmpty model =
    ( model, Cmd.none, Dispatch.none )


dragConfig : Draggable.Config WindowID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
