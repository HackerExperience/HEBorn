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
    -> Maybe AppParams
    -> Maybe Context
    -> Model
    -> ( Model, React msg )
launch config desktopApp maybeParams maybeContext model =
    let
        appContext =
            Apps.context desktopApp

        context =
            getAppActiveContext config maybeContext appContext

        getParams context_ =
            if context == context_ then
                maybeParams
            else
                Nothing

        ( model1, windowId ) =
            newWindowId model

        ( model2, instance ) =
            newInstance config desktopApp context model1

        handleApp ( appId, ( app, react ) ) ( model, react_ ) =
            ( insertApp appId app model
            , React.batch config.batchMsg [ react_, react ]
            )

        ( model_, react ) =
            instance
                |> launchInstance config desktopApp getParams windowId
                |> List.foldl handleApp ( model, React.none )
    in
        ( newWindow config windowId desktopApp instance model_, react )


lazyLaunchEndpoint :
    Config msg
    -> WindowId
    -> DesktopApp
    -> Model
    -> ( Model, React msg )
lazyLaunchEndpoint config windowId desktopApp model =
    let
        ( model1, endpointAppId ) =
            newAppId model

        maybeWindow =
            getWindow windowId model

        maybeInstance =
            case Maybe.map getInstance maybeWindow of
                Just (Double _ appId Nothing) ->
                    Just <| Double Endpoint appId (Just endpointAppId)

                maybeInstance ->
                    maybeInstance

        maybeWindow_ =
            maybeWindow
                |> Maybe.uncurry maybeInstance
                |> Maybe.map (uncurry setInstance)

        maybeAppReact =
            Maybe.map Tuple.second <|
                launchEndpoint config
                    windowId
                    desktopApp
                    Nothing
                    endpointAppId
    in
        case Maybe.uncurry maybeWindow_ maybeAppReact of
            Just ( window, ( app, react ) ) ->
                ( model
                    |> insertApp endpointAppId app
                    |> insertWindow windowId window
                , react
                )

            Nothing ->
                React.update model



---- internals


launchInstance :
    Config msg
    -> DesktopApp
    -> (Context -> Maybe AppParams)
    -> WindowId
    -> Instance
    -> List ( AppId, ( App, React msg ) )
launchInstance config desktopApp getParams windowId instance =
    let
        gateway =
            launchGateway config windowId desktopApp (getParams Gateway)

        endpoint =
            launchEndpoint config windowId desktopApp (getParams Endpoint)

        toList =
            Maybe.map List.singleton >> Maybe.withDefault []
    in
        case instance of
            Double context appId1 (Just appId2) ->
                [ gateway appId1 ] ++ (toList <| endpoint appId2)

            Double context appId Nothing ->
                [ gateway appId ]

            Single Gateway appId ->
                [ gateway appId ]

            Single Endpoint appId ->
                toList <| endpoint appId


launchGateway :
    Config msg
    -> WindowId
    -> DesktopApp
    -> Maybe AppParams
    -> AppId
    -> ( AppId, ( App, React msg ) )
launchGateway config windowId desktopApp maybeParams appId =
    -- always launch a instance for gateway
    (,) appId <|
        launchWithServer config
            windowId
            appId
            desktopApp
            maybeParams
            config.activeGateway


launchEndpoint :
    Config msg
    -> WindowId
    -> DesktopApp
    -> Maybe AppParams
    -> AppId
    -> Maybe ( AppId, ( App, React msg ) )
launchEndpoint config windowId desktopApp maybeParams appId =
    -- lazy: wont launch anything when no endpoint is selected
    case config.endpointCId of
        Just cid ->
            Maybe.map ((,) appId) <|
                launchWithCId config
                    windowId
                    appId
                    desktopApp
                    maybeParams
                    cid

        Nothing ->
            Nothing



-- low level launch app methods


launchWithCId :
    Config msg
    -> WindowId
    -> AppId
    -> DesktopApp
    -> Maybe AppParams
    -> CId
    -> Maybe ( App, React msg )
launchWithCId config windowId appId desktopApp maybeParams cid =
    -- try to launch app for CId, nothing happens when no Server
    -- is found for that CId
    case Servers.get cid config.servers of
        Just server ->
            ( cid, server )
                |> launchWithServer config
                    windowId
                    appId
                    desktopApp
                    maybeParams
                |> Just

        Nothing ->
            Nothing


launchWithServer :
    Config msg
    -> WindowId
    -> AppId
    -> DesktopApp
    -> Maybe AppParams
    -> ( CId, Server )
    -> ( App, React msg )
launchWithServer config windowId appId desktopApp maybeParams activeServer =
    -- always launch an app for a (CId, Server) tuple
    let
        ( cid, server ) =
            activeServer

        ( appModel, react ) =
            delegateLaunch config
                windowId
                appId
                desktopApp
                maybeParams
                activeServer

        context =
            if Servers.isGateway server then
                Gateway
            else
                Endpoint
    in
        ( App windowId cid appModel context
        , react
        )



-- delegates


delegateLaunch :
    Config msg
    -> WindowId
    -> AppId
    -> DesktopApp
    -> Maybe AppParams
    -> ( CId, Server )
    -> ( AppModel, React msg )
delegateLaunch config winId appId dApp params ( cid, svr ) =
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
