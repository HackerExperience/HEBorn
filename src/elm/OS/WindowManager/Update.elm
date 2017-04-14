module OS.WindowManager.Update exposing (..)

import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Core.Messages exposing (CoreMsg)
import Core.Dispatcher exposing (callDock, callWM)
import OS.Messages exposing (OSMsg(MsgWM))
import OS.WindowManager.Models
    exposing
        ( Model
        , WindowID
        , openWindow
        , closeWindow
        , updateWindowPosition
        , toggleMaximizeWindow
        , minimizeWindow
        )
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Messages as DockMsg


update : Msg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        OpenWindow window ->
            let
                ( windows_, seed_, focusID ) =
                    openWindow model window

                model_ =
                    { model | windows = windows_, seed = seed_, focus = focusID }
            in
                ( model_
                , Cmd.none
                , [ callDock (DockMsg.WindowsChanges windows_)
                  ]
                )

        CloseWindow id ->
            let
                windows_ =
                    closeWindow model id
            in
                ( { model | windows = windows_, focus = Nothing, dragging = Nothing }
                , Cmd.none
                , [ callDock (DockMsg.WindowsChanges windows_) ]
                )

        -- Drag
        OnDragBy delta ->
            let
                windows_ =
                    updateWindowPosition model delta
            in
                ( { model | windows = windows_ }, Cmd.none, [] )

        DragMsg dragMsg ->
            let
                ( model_, cmd ) =
                    Draggable.update dragConfig dragMsg model

                cmd_ =
                    Cmd.map MsgWM cmd
            in
                ( model_, cmd_, [] )

        StartDragging id ->
            ( { model | dragging = Just id, focus = Just id }
            , Cmd.none
            , []
            )

        StopDragging ->
            ( { model | dragging = Nothing }, Cmd.none, [] )

        ToggleMaximize id ->
            let
                windows_ =
                    toggleMaximizeWindow model id
            in
                ( { model | windows = windows_, dragging = Nothing }
                , Cmd.none
                , []
                )

        MinimizeWindow id ->
            let
                windows_ =
                    minimizeWindow model id
            in
                ( { model | windows = windows_, focus = Nothing, dragging = Nothing }
                , Cmd.none
                , []
                )

        UpdateFocus target ->
            ( { model | focus = target }, Cmd.none, [] )


dragConfig : Draggable.Config WindowID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
