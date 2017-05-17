module OS.WindowManager.Update exposing (..)

import Utils
import Draggable
import Draggable.Events exposing (onDragBy, onDragStart)
import Core.Messages exposing (CoreMsg(NoOp))
import Core.Dispatcher exposing (callDock, callInstance)
import OS.Messages exposing (OSMsg(MsgWM))
import OS.WindowManager.Models
    exposing
        ( Model
        , WindowID
        , getWindow
        , openWindow
        , openOrRestoreWindow
        , restoreWindow
        , closeWindow
        , updateWindowPosition
        , toggleMaximizeWindow
        , minimizeWindow
        , bringFocus
        , switchContext
        , closeAllWindows
        , minimizeAllWindows
        , OpenOrRestoreResult(..)
        )
import OS.WindowManager.Messages exposing (Msg(..))
import OS.Dock.Messages as DockMsg
import Apps.Instances.Binds as InstanceBind
import Apps.Explorer.Messages as ExplorerMsg
import OS.WindowManager.Windows exposing (GameWindow(..))


update : Msg -> Model -> ( Model, Cmd OSMsg, List CoreMsg )
update msg model =
    case msg of
        Open window ->
            let
                ( windows_, seed_, windowID ) =
                    openWindow model window

                model_ =
                    (bringFocus { model | windows = windows_, seed = seed_ } (Just windowID))

                coreMsg =
                    [ callInstance
                        (InstanceBind.open window windowID)
                    , callDock (DockMsg.WindowsChanges windows_)
                    ]
            in
                ( model_, Cmd.none, coreMsg )

        Restore windowID ->
            let
                windows_ =
                    restoreWindow windowID model.windows

                model_ =
                    bringFocus
                        { model
                            | windows = windows_
                        }
                        (Just windowID)

                coreMsg =
                    [ callDock (DockMsg.WindowsChanges windows_) ]
            in
                ( model_
                , Cmd.none
                , coreMsg
                )

        OpenOrRestore window ->
            let
                ( windows_, result_ ) =
                    openOrRestoreWindow model window

                ( model_, coreMsg ) =
                    (case result_ of
                        Create seed_ windowID ->
                            ( (bringFocus { model | windows = windows_, seed = seed_ } (Just windowID))
                            , [ callInstance
                                    (InstanceBind.open window windowID)
                              , callDock (DockMsg.WindowsChanges windows_)
                              ]
                            )

                        OneRestore windowID ->
                            ( (bringFocus { model | windows = windows_ } (Just windowID))
                            , [ callDock (DockMsg.WindowsChanges windows_) ]
                            )

                        MultiRestore ->
                            ( (bringFocus { model | windows = windows_ } Nothing)
                            , [ callDock (DockMsg.WindowsChanges windows_) ]
                            )
                    )
            in
                ( model_
                , Cmd.none
                , coreMsg
                )

        Close id ->
            let
                window =
                    (getWindow model id)

                windows_ =
                    closeWindow model id

                model_ =
                    { model
                        | windows = windows_
                        , focus = Nothing
                        , dragging = Nothing
                    }

                instanceMsg =
                    case window of
                        Just w ->
                            callInstance
                                (InstanceBind.close w.window id)

                        Nothing ->
                            NoOp

                coreMsg =
                    [ instanceMsg
                    , callDock (DockMsg.WindowsChanges windows_)
                    ]
            in
                ( model_
                , Cmd.none
                , coreMsg
                )

        Minimize id ->
            let
                windows_ =
                    minimizeWindow model id
            in
                ( { model | windows = windows_, focus = Nothing, dragging = Nothing }
                , Cmd.none
                , [ callDock (DockMsg.WindowsChanges windows_) ]
                )

        ToggleMaximize id ->
            let
                windows_ =
                    toggleMaximizeWindow model id
            in
                ( { model | windows = windows_, dragging = Nothing }
                , Cmd.none
                , []
                )

        UpdateFocusTo target ->
            ( (bringFocus model target), Cmd.none, [] )

        SwitchContext id ->
            let
                window =
                    getWindow model id

                model_ =
                    switchContext model id

                instanceMsg =
                    case window of
                        Just w ->
                            callInstance
                                ((InstanceBind.context w.window) id)

                        Nothing ->
                            NoOp

                coreMsg =
                    [ instanceMsg
                    ]
            in
                ( model_, Cmd.none, coreMsg )

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
            ( { model | dragging = Just id }
            , Cmd.none
            , []
            )

        StopDragging ->
            ( { model | dragging = Nothing }, Cmd.none, [] )

        MinimizeAll window ->
            let
                windows_ =
                    (minimizeAllWindows model.windows window)
            in
                ( { model | windows = windows_ }
                , Cmd.none
                , [ callDock (DockMsg.WindowsChanges windows_) ]
                )

        CloseAll window ->
            let
                windows_ =
                    (closeAllWindows model.windows window)
            in
                ( { model | windows = windows_ }
                , Cmd.none
                , [ callDock (DockMsg.WindowsChanges windows_) ]
                )


dragConfig : Draggable.Config WindowID Msg
dragConfig =
    Draggable.customConfig
        [ onDragBy OnDragBy
        , onDragStart StartDragging
        ]
