module OS.WindowManager.Update exposing (..)

import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Game.Models exposing (GameModel)
import Core.Messages exposing (CoreMsg(NoOp))
import Core.Dispatcher exposing (callDock)
import Core.Models exposing (CoreModel)
import Apps.Update as Apps
import Apps.Messages as Apps
import OS.Messages exposing (OSMsg(MsgWM))
import OS.WindowManager.Models
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
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Messages as DockMsg


update : Msg -> CoreModel -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg core model =
    case msg of
        Open app ->
            model
                |> openWindow app
                |> wrapEmpty
                |> refreshDock

        OpenOrRestore app ->
            model
                |> openOrRestoreWindow app
                |> wrapEmpty
                |> refreshDock

        Close windowID ->
            model
                |> closeWindow windowID
                |> unfocusWindow
                |> wrapEmpty
                |> refreshDock

        CloseAll app ->
            model
                |> closeAppWindows app
                |> unfocusWindow
                |> wrapEmpty
                |> refreshDock

        Restore windowID ->
            model
                |> restoreWindow windowID
                |> focusWindow windowID
                |> wrapEmpty
                |> refreshDock

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
                |> refreshDock

        MinimizeAll app ->
            model
                |> minimizeAppWindows app
                |> unfocusWindow
                |> wrapEmpty
                |> refreshDock

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

        SwitchContext windowID ->
            model
                |> toggleWindowContext windowID
                |> wrapEmpty

        OnDragBy delta ->
            model
                |> updateWindowPosition delta
                |> wrapEmpty

        DragMsg dragMsg ->
            let
                ( model_, cmd ) =
                    Draggable.update dragConfig dragMsg model
            in
                ( model_, Cmd.map MsgWM cmd, [] )

        StartDragging windowID ->
            model
                |> startDragging windowID
                |> wrapEmpty

        StopDragging ->
            model
                |> stopDragging
                |> wrapEmpty

        WindowMsg windowID msg ->
            let
                ( model_, cmd, msgs ) =
                    updateApp core.game windowID msg model

                cmd_ =
                    cmd
                        |> Cmd.map (WindowMsg windowID)
                        |> Cmd.map MsgWM
            in
                ( model_, cmd_, msgs )



-- internals


updateApp :
    GameModel
    -> WindowID
    -> Apps.AppMsg
    -> Model
    -> ( Model, Cmd Apps.AppMsg, List CoreMsg )
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


wrapEmpty : Model -> ( Model, Cmd OSMsg, List CoreMsg )
wrapEmpty model =
    ( model, Cmd.none, [] )


refreshDock : ( Model, Cmd OSMsg, List CoreMsg ) -> ( Model, Cmd OSMsg, List CoreMsg )
refreshDock ( { windows } as model, cmd, msgs ) =
    ( model, cmd, callDock (DockMsg.WindowsChanges windows) :: msgs )


dragConfig : Draggable.Config WindowID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
