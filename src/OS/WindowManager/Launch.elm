module OS.WindowManager.Launch exposing (launch)

import Utils.Maybe as Maybe
import Utils.React as React exposing (React)
import Apps.Params as Apps exposing (AppParams)
import Apps.Shared as Apps exposing (AppContext)
import Apps.BackFlix.Models as BackFlix
import Apps.BounceManager.Launch as BounceManager
import Apps.Browser.Launch as Browser
import Apps.Bug.Models as Bug
import Apps.Calculator.Models as Calculator
import Apps.Calculator.Messages as Calculator
import Apps.ConnManager.Models as ConnManager
import Apps.CtrlPanel.Models as CtrlPanel
import Apps.DBAdmin.Models as DBAdmin
import Apps.Email.Models as Email
import Apps.Explorer.Models as Explorer
import Apps.Finance.Models as Finance
import Apps.FloatingHeads.Launch as FloatingHeads
import Apps.Hebamp.Launch as Hebamp
import Apps.LanViewer.Models as LanViewer
import Apps.LocationPicker.Models as LocationPicker
import Apps.LogViewer.Models as LogViewer
import Apps.ServersGears.Models as ServersGears
import Apps.TaskManager.Models as TaskManager
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Models as Servers exposing (Server)
import Game.Servers.Shared as Servers exposing (CId)
import OS.WindowManager.Config exposing (..)
import OS.WindowManager.Helpers exposing (..)
import OS.WindowManager.Messages exposing (..)
import OS.WindowManager.Models exposing (..)
import OS.WindowManager.Shared exposing (..)


launch :
    Config msg
    -> DesktopApp
    -> Maybe Context
    -> Maybe AppParams
    -> Model
    -> ( Model, React msg )
launch config desktopApp maybeContext maybeParams model =
    let
        ( model1, windowId ) =
            newWindowId model

        contexts =
            Apps.context desktopApp

        context =
            getAppActiveContext config maybeContext contexts

        launchGateway =
            case context of
                Gateway ->
                    launchApp config Gateway windowId desktopApp maybeParams

                Endpoint ->
                    launchApp config Gateway windowId desktopApp Nothing

        launchEndpoint =
            case context of
                Gateway ->
                    launchApp config Endpoint windowId desktopApp Nothing

                Endpoint ->
                    launchApp config Endpoint windowId desktopApp maybeParams

        ( model2, mainAppId, react1 ) =
            case contexts of
                Apps.DynamicContext ->
                    launchGateway model1

                Apps.StaticContext Gateway ->
                    launchGateway model1

                Apps.StaticContext Endpoint ->
                    launchEndpoint model1

        ( model3, maybeOtherAppId, react2 ) =
            case contexts of
                Apps.DynamicContext ->
                    let
                        ( m, i, r ) =
                            launchEndpoint model2
                    in
                        ( m, Just i, r )

                Apps.StaticContext _ ->
                    ( model2, Nothing, React.none )

        instance =
            case contexts of
                Apps.DynamicContext ->
                    Double context mainAppId maybeOtherAppId

                Apps.StaticContext _ ->
                    Single context mainAppId

        hasDecoration =
            case Maybe.map getModel <| getApp mainAppId model3 of
                Just appModel ->
                    isDecorated appModel

                Nothing ->
                    True

        sessionId =
            getSessionId config

        maybePosition =
            model
                |> getSession sessionId
                |> getFocusing
                |> Maybe.andThen (flip getWindow model)
                |> Maybe.map getPosition

        position =
            case maybePosition of
                Just { x, y } ->
                    Position (x + 32) (y + 32)

                Nothing ->
                    Position 32 (44 + 32)

        window =
            { position = position
            , size = (uncurry Size <| Apps.windowInitSize desktopApp)
            , maximized = False
            , decorated = hasDecoration
            , instance = instance
            , originSessionId = sessionId
            }
    in
        ( insert windowId window model3
        , React.batch config.batchMsg [ react1, react2 ]
        )



-- internals


launchApp :
    Config msg
    -> Context
    -> WindowId
    -> DesktopApp
    -> Maybe AppParams
    -> Model
    -> ( Model, AppId, React msg )
launchApp config context windowId desktopApp maybeParams model =
    let
        activeServer =
            case context of
                Gateway ->
                    config.activeGateway

                Endpoint ->
                    case config.endpointCId of
                        Just id ->
                            config.servers
                                |> Servers.get id
                                |> Maybe.map ((,) id)
                                |> Maybe.withDefault config.activeServer

                        Nothing ->
                            -- this may
                            config.activeServer

        ( model_, appId ) =
            newAppId model

        ( appModel, react ) =
            delegateLaunch config
                activeServer
                windowId
                appId
                desktopApp
                maybeParams

        app =
            App windowId (Tuple.first activeServer) appModel
    in
        ( insertApp appId app model_, appId, react )


delegateLaunch :
    Config msg
    -> ( CId, Server )
    -> WindowId
    -> AppId
    -> DesktopApp
    -> Maybe AppParams
    -> ( AppModel, React msg )
delegateLaunch config ( cid, svr ) winId appId dApp params =
    case dApp of
        DesktopApp.BackFlix ->
            ( BackFlixModel BackFlix.initialModel
            , React.none
            )

        DesktopApp.BounceManager ->
            params
                |> Maybe.andThen Apps.castBounceManager
                |> BounceManager.launch
                    (bounceManagerConfig appId config)
                |> Tuple.mapFirst BounceManagerModel

        DesktopApp.Browser ->
            params
                |> Maybe.andThen Apps.castBrowser
                |> Browser.launch (browserConfig appId cid svr config)
                |> Tuple.mapFirst BrowserModel

        DesktopApp.Bug ->
            ( BugModel Bug.initialModel
            , React.none
            )

        DesktopApp.Calculator ->
            ( CalculatorModel Calculator.initialModel
            , React.none
            )

        DesktopApp.ConnManager ->
            ( ConnManagerModel ConnManager.initialModel
            , React.none
            )

        DesktopApp.CtrlPanel ->
            ( CtrlPanelModel CtrlPanel.initialModel
            , React.none
            )

        DesktopApp.DBAdmin ->
            ( DBAdminModel DBAdmin.initialModel
            , React.none
            )

        DesktopApp.Email ->
            ( EmailModel Email.initialModel
            , React.none
            )

        DesktopApp.Explorer ->
            ( ExplorerModel Explorer.initialModel
            , React.none
            )

        DesktopApp.Finance ->
            ( FinanceModel Finance.initialModel
            , React.none
            )

        DesktopApp.FloatingHeads ->
            params
                |> Maybe.andThen Apps.castFloatingHeads
                |> FloatingHeads.launch
                    (floatingHeadsConfig winId appId cid config)
                |> Tuple.mapFirst FloatingHeadsModel

        DesktopApp.Hebamp ->
            params
                |> Maybe.andThen Apps.castHebamp
                |> Hebamp.launch
                    (hebampConfig winId appId config)
                |> Tuple.mapFirst HebampModel

        DesktopApp.LanViewer ->
            ( LanViewerModel LanViewer.initialModel
            , React.none
            )

        DesktopApp.LocationPicker ->
            launchLocationPicker config winId appId

        DesktopApp.LogViewer ->
            ( LogViewerModel LogViewer.initialModel
            , React.none
            )

        DesktopApp.ServersGears ->
            config
                |> serversGearsConfig appId cid svr
                |> .mobo
                |> ServersGears.initialModel
                |> ServersGearsModel
                |> flip (,) React.none

        DesktopApp.TaskManager ->
            ( TaskManagerModel TaskManager.initialModel
            , React.none
            )


launchLocationPicker : Config msg -> WindowId -> AppId -> ( AppModel, React msg )
launchLocationPicker config windowId appId =
    let
        model =
            LocationPicker.initialModel windowId

        react =
            model
                |> LocationPicker.startCmd
                |> Cmd.map (LocationPickerMsg >> AppMsg appId >> config.toMsg)
                |> React.cmd
    in
        ( LocationPickerModel model, react )



-- helpers


getAppActiveContext : Config msg -> Maybe Context -> AppContext -> Context
getAppActiveContext config maybeContext appContext =
    case maybeContext of
        Just context ->
            context

        Nothing ->
            case appContext of
                Apps.DynamicContext ->
                    if config.activeServer == config.activeGateway then
                        Gateway
                    else
                        Endpoint

                Apps.StaticContext context ->
                    context
