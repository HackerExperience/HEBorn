module OS.WindowManager.Update exposing (..)

import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Core.Messages exposing (CoreMsg)
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


update : Msg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        OpenWindow window ->
            let
                ( windows_, seed_ ) =
                    openWindow model window

                model_ =
                    { model | windows = windows_, seed = seed_ }
            in
                ( model_, Cmd.none, [] )

        CloseWindow id ->
            let
                windows_ =
                    closeWindow model id
            in
                ( { model | windows = windows_ }, Cmd.none, [] )

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
            ( { model | dragging = Just id }, Cmd.none, [] )

        StopDragging ->
            ( { model | dragging = Nothing }, Cmd.none, [] )

        ToggleMaximize id ->
            let
                windows_ =
                    toggleMaximizeWindow model id
            in
                ( { model | windows = windows_ }, Cmd.none, [] )

        MinimizeWindow id ->
            let
                windows_ =
                    minimizeWindow model id
            in
                ( { model | windows = windows_ }, Cmd.none, [] )


dragConfig : Draggable.Config WindowID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
