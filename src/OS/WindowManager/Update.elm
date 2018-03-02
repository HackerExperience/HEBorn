module OS.WindowManager.Update exposing (update)

import Draggable
import Window
import Utils.Maybe as Maybe
import Utils.React as React exposing (React)
import Apps.Params as AppsParams exposing (AppParams)
import Apps.BackFlix.Update as BackFlix
import Apps.BounceManager.Messages as BounceManager
import Apps.BounceManager.Update as BounceManager
import Apps.Browser.Update as Browser
import Apps.Browser.Messages as Browser
import Apps.Bug.Update as Bug
import Apps.Calculator.Update as Calculator
import Apps.ConnManager.Update as ConnManager
import Apps.DBAdmin.Update as DBAdmin
import Apps.Email.Update as Email
import Apps.Explorer.Update as Explorer
import Apps.Finance.Update as Finance
import Apps.FloatingHeads.Update as FloatingHeads
import Apps.FloatingHeads.Messages as FloatingHeads
import Apps.Hebamp.Update as Hebamp
import Apps.Hebamp.Messages as Hebamp
import Apps.LocationPicker.Update as LocationPicker
import Apps.LogViewer.Update as LogViewer
import Apps.ServersGears.Update as ServersGears
import Apps.TaskManager.Update as TaskManager
import Apps.VirusPanel.Update as VirusPanel
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId(..))
import OS.WindowManager.Config exposing (..)
import OS.WindowManager.Helpers exposing (..)
import OS.WindowManager.Launch exposing (..)
import OS.WindowManager.Messages exposing (..)
import OS.WindowManager.Models exposing (..)
import OS.WindowManager.Shared exposing (..)
import OS.WindowManager.Sidebar.Messages as Sidebar
import OS.WindowManager.Sidebar.Update as Sidebar


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        NewApp desktopApp maybeContext maybeParams cid ->
            launch config desktopApp maybeParams maybeContext cid model

        OpenApp params cid ->
            onOpenApp config params cid model

        LazyLaunchEndpoint windowId desktopApp ->
            lazyLaunchEndpoint config windowId desktopApp model

        SetAppSize size_ ->
            onSetAppSize size_ model

        SidebarMsg msg ->
            onSidebarMsg config msg model

        -- window handling
        Close wId ->
            React.update <| close wId model

        Minimize wId ->
            React.update <| minimize (getSessionId config) wId model

        ToggleMaximize wId ->
            withWindow wId model <| toggleMaximize >> React.update

        ToggleContext wId ->
            withWindow wId model <| toggleContext >> React.update

        SelectContext context wId ->
            withWindow wId model <| setContext context >> React.update

        UpdateFocus maybeWId ->
            React.update <| focus (getSessionId config) maybeWId model

        TogglePin windowId ->
            React.update <| togglePin windowId model

        -- drag messages
        StartDrag wId ->
            React.update <| startDragging wId (getSessionId config) model

        Dragging ( x, y ) ->
            onDragging x y model

        StopDrag ->
            React.update <| stopDragging model

        DragMsg msg ->
            onDragMsg config msg model

        -- dock messages
        ClickIcon desktopApp ->
            onClickIcon config desktopApp model

        MinimizeAll app ->
            React.update <| minimizeAll app (getSessionId config) model

        CloseAll app ->
            React.update <| closeAll app (getSessionId config) model

        -- app messages
        AppMsg appId appMsg ->
            updateApp config appId appMsg model

        AppsMsg appMsg ->
            updateApps config appMsg model


onSetAppSize : Window.Size -> Model -> UpdateResponse msg
onSetAppSize size_ model =
    { model | appSize = Just size_ }
        |> flip (,) React.none


onSidebarMsg :
    Config msg
    -> Sidebar.Msg
    -> Model
    -> UpdateResponse msg
onSidebarMsg config msg model =
    let
        config_ =
            sidebarConfig config

        ( sidebar, react ) =
            Sidebar.update
                (sidebarConfig config)
                msg
                (getSidebar model)

        model_ =
            setSidebar sidebar model
    in
        ( model_, react )


onOpenApp : Config msg -> AppParams -> CId -> Model -> UpdateResponse msg
onOpenApp config params cid model =
    let
        desktopApp =
            AppsParams.toAppType params

        maybeAppId =
            findExistingAppId desktopApp cid model

        maybeContext =
            case endpointCIdFromConfig config of
                Just endpointCId ->
                    if endpointCId == cid then
                        Just Endpoint
                    else
                        Just Gateway

                Nothing ->
                    Nothing
    in
        case maybeAppId of
            Just appId ->
                -- it's probably worth to restore the window unless we can't
                -- guarantee that the launch event will always reuse an
                -- existing window
                updateAppParams config appId params model

            Nothing ->
                launch config desktopApp (Just params) maybeContext cid model


withWindow :
    WindowId
    -> Model
    -> (Window -> ( Window, React msg ))
    -> UpdateResponse msg
withWindow windowId model map =
    let
        andMap ( window, react ) =
            ( insertWindow windowId window model, react )
    in
        model
            |> getWindow windowId
            |> Maybe.map (map >> andMap)
            |> Maybe.withDefault ( model, React.none )


onDragging : Float -> Float -> Model -> UpdateResponse msg
onDragging x y model =
    case getDragging model of
        Just windowId ->
            withWindow windowId model (smartMove model x y >> React.update)

        Nothing ->
            React.update model


onDragMsg : Config msg -> Draggable.Msg WindowId -> Model -> UpdateResponse msg
onDragMsg config msg model =
    model
        |> Draggable.update (dragConfig config) msg
        |> Tuple.mapSecond React.cmd


onClickIcon : Config msg -> DesktopApp -> Model -> UpdateResponse msg
onClickIcon config desktopApp model =
    let
        sessionId =
            getSessionId config

        context =
            if config.activeGateway == config.activeServer then
                Gateway
            else
                Endpoint

        ( model_, shouldLaunch ) =
            openOrRestoreApp desktopApp sessionId model
    in
        if shouldLaunch then
            launch config desktopApp Nothing (Just context) sessionId model_
        else
            React.update model_


updateAppParams :
    Config msg
    -> AppId
    -> AppParams
    -> Model
    -> UpdateResponse msg
updateAppParams config appId params model =
    case params of
        AppsParams.BounceManager params ->
            updateApp config
                appId
                (BounceManagerMsg <| BounceManager.LaunchApp params)
                model

        AppsParams.Browser params ->
            updateApp config
                appId
                (BrowserMsg <| Browser.LaunchApp params)
                model

        AppsParams.FloatingHeads params ->
            updateApp config
                appId
                (FloatingHeadsMsg <| FloatingHeads.LaunchApp params)
                model

        AppsParams.Hebamp params ->
            updateApp config
                appId
                (HebampMsg <| Hebamp.LaunchApp params)
                model


updateApp : Config msg -> AppId -> AppMsg -> Model -> UpdateResponse msg
updateApp config appId appMsg model =
    let
        maybeApp =
            getApp appId model

        maybeWindowId =
            getWindowOfApp appId model

        maybeWindow =
            Maybe.andThen (flip getWindow model) maybeWindowId

        maybeActiveServer =
            Maybe.andThen (getAppActiveServer config) maybeApp

        maybeActiveGateway =
            Maybe.andThen (getGatewayOfWindow config model) maybeWindow

        uncurried =
            case Maybe.uncurry maybeActiveServer maybeActiveGateway of
                Just ( active, gateway ) ->
                    case Maybe.uncurry maybeWindowId maybeApp of
                        Just ( windowId, app ) ->
                            Just ( windowId, app, active, gateway )

                        Nothing ->
                            Nothing

                Nothing ->
                    Nothing
    in
        case uncurried of
            Just ( windowId, app, active, gateway ) ->
                let
                    ( appModel, react ) =
                        updateAppDelegate config
                            active
                            gateway
                            appMsg
                            windowId
                            appId
                            app
                in
                    ( insertApp appId (setModel appModel app) model
                    , react
                    )

            Nothing ->
                React.update model


updateAppDelegate :
    Config msg
    -> ( CId, Server )
    -> ( CId, Server )
    -> AppMsg
    -> WindowId
    -> AppId
    -> App
    -> ( AppModel, React msg )
updateAppDelegate config activeServer activeGateway appMsg windowId appId app =
    -- HACK : Elm's Tuple Pattern Matching is slow
    -- https://groups.google.com/forum/#!topic/elm-dev/QGmwWH6V8-c
    case appMsg of
        BackFlixMsg msg ->
            case getModel app of
                BackFlixModel appModel ->
                    appModel
                        |> BackFlix.update (backFlixConfig appId config) msg
                        |> Tuple.mapFirst BackFlixModel

                model ->
                    React.update model

        BounceManagerMsg msg ->
            case getModel app of
                BounceManagerModel appModel ->
                    appModel
                        |> BounceManager.update
                            (bounceManagerConfig appId config)
                            msg
                        |> Tuple.mapFirst BounceManagerModel

                model ->
                    React.update model

        BrowserMsg msg ->
            case getModel app of
                BrowserModel appModel ->
                    appModel
                        |> Browser.update
                            (browserConfig appId
                                activeServer
                                activeGateway
                                config
                            )
                            msg
                        |> Tuple.mapFirst BrowserModel

                model ->
                    React.update model

        BugMsg msg ->
            case getModel app of
                BugModel appModel ->
                    appModel
                        |> Bug.update (bugConfig appId config) msg
                        |> Tuple.mapFirst BugModel

                model ->
                    React.update model

        CalculatorMsg msg ->
            case getModel app of
                CalculatorModel appModel ->
                    appModel
                        |> Calculator.update (calculatorConfig appId config)
                            msg
                        |> Tuple.mapFirst CalculatorModel

                model ->
                    React.update model

        ConnManagerMsg msg ->
            case getModel app of
                ConnManagerModel appModel ->
                    appModel
                        |> ConnManager.update (connManagerConfig appId config)
                            msg
                        |> Tuple.mapFirst ConnManagerModel

                model ->
                    React.update model

        DBAdminMsg msg ->
            case getModel app of
                DBAdminModel appModel ->
                    appModel
                        |> DBAdmin.update (dbAdminConfig appId config) msg
                        |> Tuple.mapFirst DBAdminModel

                model ->
                    React.update model

        EmailMsg msg ->
            case getModel app of
                EmailModel appModel ->
                    appModel
                        |> Email.update
                            (emailConfig appId activeGateway config)
                            msg
                        |> Tuple.mapFirst EmailModel

                model ->
                    React.update model

        ExplorerMsg msg ->
            case getModel app of
                ExplorerModel appModel ->
                    appModel
                        |> Explorer.update
                            (explorerConfig appId activeServer config)
                            msg
                        |> Tuple.mapFirst ExplorerModel

                model ->
                    React.update model

        FinanceMsg msg ->
            case getModel app of
                FinanceModel appModel ->
                    appModel
                        |> Finance.update (financeConfig appId config) msg
                        |> Tuple.mapFirst FinanceModel

                model ->
                    React.update model

        FloatingHeadsMsg msg ->
            case getModel app of
                FloatingHeadsModel appModel ->
                    appModel
                        |> FloatingHeads.update
                            (floatingHeadsConfig windowId
                                appId
                                activeGateway
                                config
                            )
                            msg
                        |> Tuple.mapFirst FloatingHeadsModel

                model ->
                    React.update model

        HebampMsg msg ->
            case getModel app of
                HebampModel appModel ->
                    appModel
                        |> Hebamp.update
                            (hebampConfig windowId appId config)
                            msg
                        |> Tuple.mapFirst HebampModel

                model ->
                    React.update model

        LocationPickerMsg msg ->
            case getModel app of
                LocationPickerModel appModel ->
                    appModel
                        |> LocationPicker.update
                            (locationPickerConfig appId config)
                            msg
                        |> Tuple.mapFirst LocationPickerModel

                model ->
                    React.update model

        LogViewerMsg msg ->
            case getModel app of
                LogViewerModel appModel ->
                    appModel
                        |> LogViewer.update
                            (logViewerConfig appId activeServer config)
                            msg
                        |> Tuple.mapFirst LogViewerModel

                model ->
                    React.update model

        ServersGearsMsg msg ->
            case getModel app of
                ServersGearsModel appModel ->
                    appModel
                        |> ServersGears.update
                            (serversGearsConfig appId activeServer config)
                            msg
                        |> Tuple.mapFirst ServersGearsModel

                model ->
                    React.update model

        TaskManagerMsg msg ->
            case getModel app of
                TaskManagerModel appModel ->
                    appModel
                        |> TaskManager.update
                            (taskManagerConfig appId activeServer config)
                            msg
                        |> Tuple.mapFirst TaskManagerModel

                model ->
                    React.update model

        VirusPanelMsg msg ->
            case getModel app of
                VirusPanelModel appModel ->
                    appModel
                        |> VirusPanel.update
                            (virusPanelConfig appId activeGateway config)
                            msg
                        |> Tuple.mapFirst VirusPanelModel

                model ->
                    React.update model


updateApps : Config msg -> AppMsg -> Model -> UpdateResponse msg
updateApps config appMsg model =
    let
        reducer appId ( model, list ) =
            let
                ( model_, react ) =
                    updateApp config appId appMsg model
            in
                ( model, react :: list )
    in
        model
            |> listAppsOfType (msgToDesktopApp appMsg)
            |> List.foldl reducer ( model, [] )
            |> Tuple.mapSecond (React.batch config.batchMsg)
