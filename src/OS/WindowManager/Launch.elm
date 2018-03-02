module OS.WindowManager.Launch exposing (launch, lazyLaunchEndpoint)

import Utils.Maybe as Maybe
import Utils.React as React exposing (React)
import Apps.Params as Apps exposing (AppParams)
import Apps.Shared as Apps exposing (AppContext)
import Apps.BackFlix.Models as BackFlix
import Apps.BounceManager.Launch as BounceManager
import Apps.Browser.Launch as Browser
import Apps.Bug.Models as Bug
import Apps.Calculator.Models as Calculator
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
import Apps.VirusPanel.Models as VirusPanel
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
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
    -> Maybe AppParams
    -> Maybe Context
    -> CId
    -> Model
    -> ( Model, React msg )
launch config desktopApp maybeParams maybeContext cid model =
    case Servers.get cid <| serversFromConfig config of
        Just server ->
            case Apps.context desktopApp of
                Apps.DynamicContext ->
                    launchDoubleHelper config
                        desktopApp
                        maybeParams
                        (Maybe.withDefault Gateway maybeContext)
                        ( cid, server )
                        model

                Apps.StaticContext Gateway ->
                    launchSingleHelper config
                        desktopApp
                        maybeParams
                        Gateway
                        ( cid, server )
                        model

                Apps.StaticContext Endpoint ->
                    launchSingleHelper config
                        desktopApp
                        maybeParams
                        Endpoint
                        ( cid, server )
                        model

        Nothing ->
            ( model, React.none )


lazyLaunchEndpoint :
    Config msg
    -> WindowId
    -> DesktopApp
    -> Model
    -> ( Model, React msg )
lazyLaunchEndpoint config windowId desktopApp model =
    let
        maybeWindow =
            getWindow windowId model

        maybeActiveEndpoint =
            Maybe.andThen (getEndpointOfWindow config model) maybeWindow

        maybeAcitveGateway =
            Maybe.andThen (getGatewayOfWindow config model) maybeWindow
    in
        case Maybe.uncurry maybeActiveEndpoint maybeAcitveGateway of
            Just ( activeEndpoint, activeGateway ) ->
                Tuple.second <|
                    launchAppHelper config
                        activeEndpoint
                        activeGateway
                        desktopApp
                        Nothing
                        windowId
                        model

            Nothing ->
                ( model, React.none )



-- internals


launchDoubleHelper :
    Config msg
    -> DesktopApp
    -> Maybe AppParams
    -> Context
    -> ( CId, Server )
    -> Model
    -> ( Model, React msg )
launchDoubleHelper config desktopApp maybeParams context activeGateway model =
    let
        ( gatewayParams, endpointParams ) =
            case context of
                Gateway ->
                    ( maybeParams, Nothing )

                Endpoint ->
                    ( Nothing, maybeParams )

        ( gatewayCid, gateway ) =
            activeGateway

        maybeActiveEndpoint =
            getEndpointOfGateway config gateway

        maybeActiveCId =
            case context of
                Gateway ->
                    Just <| Tuple.first activeGateway

                Endpoint ->
                    Maybe.map Tuple.first maybeActiveEndpoint

        ( windowId, model1 ) =
            getNewWindowId model

        size =
            uncurry Size <| Apps.windowInitSize desktopApp

        ( appId, ( model2, react1 ) ) =
            launchAppHelper config
                activeGateway
                activeGateway
                desktopApp
                gatewayParams
                windowId
                model1

        instance =
            Double context appId Nothing

        model3 =
            case maybeActiveCId of
                Just cid ->
                    let
                        model_ =
                            insert cid windowId size instance model2
                    in
                        if (Tuple.first config.activeServer) /= cid then
                            pin windowId model_
                        else
                            model_

                Nothing ->
                    model2
    in
        case getEndpointOfGateway config gateway of
            Just activeEndpoint ->
                let
                    ( model_, react2 ) =
                        Tuple.second <|
                            launchAppHelper config
                                activeEndpoint
                                activeGateway
                                desktopApp
                                endpointParams
                                windowId
                                model3

                    react_ =
                        React.batch config.batchMsg [ react1, react2 ]
                in
                    ( model_, react_ )

            Nothing ->
                ( model3, react1 )


launchSingleHelper :
    Config msg
    -> DesktopApp
    -> Maybe AppParams
    -> Context
    -> ( CId, Server )
    -> Model
    -> ( Model, React msg )
launchSingleHelper config desktopApp maybeParams context activeGateway model =
    case getActiveServer config context activeGateway of
        Just activeServer ->
            let
                cid =
                    Tuple.first activeServer

                ( windowId, model1 ) =
                    getNewWindowId model

                size =
                    uncurry Size <| Apps.windowInitSize desktopApp

                ( appId, ( model2, react ) ) =
                    launchAppHelper config
                        activeServer
                        activeGateway
                        desktopApp
                        maybeParams
                        windowId
                        model1

                instance =
                    Single context appId

                model3 =
                    insert cid windowId size instance model2

                model_ =
                    if config.activeServer /= activeServer then
                        pin windowId model3
                    else
                        model3
            in
                ( model_, react )

        Nothing ->
            ( model, React.none )


launchAppHelper :
    Config msg
    -> ( CId, Server )
    -> ( CId, Server )
    -> DesktopApp
    -> Maybe AppParams
    -> WindowId
    -> Model
    -> ( AppId, ( Model, React msg ) )
launchAppHelper config activeServer activeGateway desktopApp maybeParams windowId model =
    let
        ( appId, model1 ) =
            getNewAppId model

        ( appModel, react ) =
            launchDelegate config
                activeServer
                activeGateway
                windowId
                appId
                desktopApp
                maybeParams

        ( cid, server ) =
            activeServer

        context =
            if Servers.isGateway server then
                Gateway
            else
                Endpoint

        app =
            App context cid appModel

        model2 =
            model1
                |> insertApp appId app
                |> linkAppWindow appId windowId

        model_ =
            case context of
                Gateway ->
                    model2

                Endpoint ->
                    linkEndpointApp appId windowId model2
    in
        ( appId, ( model_, react ) )



---- delegates


launchDelegate :
    Config msg
    -> ( CId, Server )
    -> ( CId, Server )
    -> WindowId
    -> AppId
    -> DesktopApp
    -> Maybe AppParams
    -> ( AppModel, React msg )
launchDelegate config activeServer activeGateway windowId appId desktopApp maybeParams =
    case desktopApp of
        DesktopApp.BackFlix ->
            ( BackFlixModel BackFlix.initialModel
            , React.none
            )

        DesktopApp.BounceManager ->
            maybeParams
                |> Maybe.andThen Apps.castBounceManager
                |> BounceManager.launch
                    (bounceManagerConfig appId config)
                |> Tuple.mapFirst BounceManagerModel

        DesktopApp.Browser ->
            maybeParams
                |> Maybe.andThen Apps.castBrowser
                |> Browser.launch
                    (browserConfig appId activeServer activeGateway config)
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
            maybeParams
                |> Maybe.andThen Apps.castFloatingHeads
                |> FloatingHeads.launch
                    (floatingHeadsConfig windowId appId activeServer config)
                |> Tuple.mapFirst FloatingHeadsModel

        DesktopApp.Hebamp ->
            maybeParams
                |> Maybe.andThen Apps.castHebamp
                |> Hebamp.launch
                    (hebampConfig windowId appId config)
                |> Tuple.mapFirst HebampModel

        DesktopApp.LanViewer ->
            ( LanViewerModel LanViewer.initialModel
            , React.none
            )

        DesktopApp.LocationPicker ->
            launchLocationPicker config windowId appId

        DesktopApp.LogViewer ->
            ( LogViewerModel LogViewer.initialModel
            , React.none
            )

        DesktopApp.ServersGears ->
            config
                |> serversGearsConfig appId activeServer
                |> .mobo
                |> ServersGears.initialModel
                |> ServersGearsModel
                |> flip (,) React.none

        DesktopApp.TaskManager ->
            ( TaskManagerModel TaskManager.initialModel
            , React.none
            )

        DesktopApp.VirusPanel ->
            ( VirusPanelModel VirusPanel.initialModel
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
