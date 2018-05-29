module OS.WindowManager.Models exposing (..)

import Dict exposing (Dict)
import Draggable
import Random.Pcg as Random
import Uuid
import Apps.BackFlix.Models as BackFlix
import Apps.BounceManager.Models as BounceManager
import Apps.Browser.Models as Browser
import Apps.Bug.Models as Bug
import Apps.Calculator.Models as Calculator
import Apps.ConnManager.Models as ConnManager
import Apps.CtrlPanel.Models as CtrlPanel
import Apps.DBAdmin.Models as DBAdmin
import Apps.Email.Models as Email
import Apps.Explorer.Models as Explorer
import Apps.Finance.Models as Finance
import Apps.FloatingHeads.Models as FloatingHeads
import Apps.Hebamp.Models as Hebamp
import Apps.LanViewer.Models as LanViewer
import Apps.LocationPicker.Models as LocationPicker
import Apps.LogViewer.Models as LogViewer
import Apps.ServersGears.Models as ServersGears
import Apps.TaskManager.Models as TaskManager
import Apps.VirusPanel.Models as VirusPanel
import Game.Meta.Types.Desktop.Apps as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Shared as Servers exposing (CId)
import OS.WindowManager.Shared exposing (..)
import OS.WindowManager.Sidebar.Models as Sidebar


type alias Model =
    { apps : Apps
    , windows : Windows
    , sessions : Sessions
    , dragging : Maybe WindowId
    , windowOfApps : WindowOfApps
    , sessionOfWindows : SessionOfWindows
    , pinned : Pinned
    , seed : Random.Seed
    , drag : Draggable.State WindowId
    , appSize : Maybe Size
    , sidebar : Sidebar.Model
    }



-- apps


type alias Apps =
    Dict AppId App


type alias App =
    { context : Context
    , cid : CId
    , model : AppModel
    }


type AppModel
    = BackFlixModel BackFlix.Model
    | BounceManagerModel BounceManager.Model
    | BrowserModel Browser.Model
    | BugModel Bug.Model
    | CalculatorModel Calculator.Model
    | ConnManagerModel ConnManager.Model
    | CtrlPanelModel CtrlPanel.Model
    | DBAdminModel DBAdmin.Model
    | EmailModel Email.Model
    | ExplorerModel Explorer.Model
    | FinanceModel Finance.Model
    | FloatingHeadsModel FloatingHeads.Model
    | HebampModel Hebamp.Model
    | LanViewerModel LanViewer.Model
    | LocationPickerModel LocationPicker.Model
    | LogViewerModel LogViewer.Model
    | ServersGearsModel ServersGears.Model
    | TaskManagerModel TaskManager.Model
    | VirusPanelModel VirusPanel.Model



-- windows


type alias Windows =
    Dict WindowId Window


type alias Window =
    { position : Position
    , size : Size
    , maximized : IsMaximized
    , instance : Instance
    }


type alias Position =
    { x : Float
    , y : Float
    }


type alias Size =
    { width : Int
    , height : Int
    }


type alias IsMaximized =
    Bool


type alias IsDecorated =
    Bool


type Instance
    = Single Context AppId
    | Double Context AppId (Maybe AppId)



-- sessions


type alias Sessions =
    Dict SessionId Session


type alias Session =
    { hidden : Index
    , visible : Index
    , focusing : Maybe WindowId
    , cid : CId
    }


type alias Index =
    List WindowId



-- references


type alias WindowOfApps =
    Dict AppId WindowId


type alias SessionOfWindows =
    Dict WindowId CId


type alias Pinned =
    { hidden : Index
    , visible : Index
    }



-- affecting model


initialModel : Model
initialModel =
    { apps = Dict.empty
    , windows = Dict.empty
    , sessions = Dict.empty
    , windowOfApps = Dict.empty
    , sessionOfWindows = Dict.empty
    , dragging = Nothing
    , pinned = Pinned [] []
    , seed = Random.initialSeed 844121764423
    , drag = Draggable.init
    , appSize = Nothing
    , sidebar = Sidebar.initialModel
    }


insert : CId -> WindowId -> Size -> Instance -> Model -> Model
insert cid windowId size instance model =
    let
        position =
            getNewWindowPosition cid model

        window =
            Window
                position
                size
                False
                instance

        model_ =
            model
                |> insertWindow windowId window
                |> linkWindowSession windowId cid

        session =
            model_
                |> getSession cid
                |> focusWindow (Just windowId)
    in
        insertSession cid session model_


getNewAppId : Model -> ( AppId, Model )
getNewAppId =
    getUuid


insertApp : AppId -> App -> Model -> Model
insertApp appId app model =
    { model | apps = Dict.insert appId app model.apps }


getApp : AppId -> Model -> Maybe App
getApp appId =
    .apps >> Dict.get appId


getNewWindowId : Model -> ( WindowId, Model )
getNewWindowId =
    getUuid


insertWindow : WindowId -> Window -> Model -> Model
insertWindow windowId window model =
    { model | windows = Dict.insert windowId window model.windows }


getWindow : WindowId -> Model -> Maybe Window
getWindow windowId =
    .windows >> Dict.get windowId


insertSession : CId -> Session -> Model -> Model
insertSession cid session model =
    { model | sessions = Dict.insert (cidToSessionId cid) session model.sessions }


getSession : CId -> Model -> Session
getSession cid ({ pinned } as model) =
    case Dict.get (cidToSessionId cid) model.sessions of
        Just session ->
            session

        Nothing ->
            Session pinned.hidden pinned.visible Nothing cid


minimize : CId -> WindowId -> Model -> Model
minimize cid windowId model =
    let
        model_ =
            model
                |> getSession cid
                |> minimizeWindow windowId
                |> flip (insertSession cid) model
    in
        if List.member windowId model.pinned.visible then
            filterVisiblePinned windowId model_
        else
            model_


focus : CId -> Maybe WindowId -> Model -> Model
focus cid maybeWindowId model =
    let
        model_ =
            model
                |> getSession cid
                |> focusWindow maybeWindowId
                |> flip (insertSession cid) model
    in
        case maybeWindowId of
            Just windowId ->
                if List.member windowId model.pinned.hidden then
                    insertVisiblePinned windowId model_
                else
                    model_

            Nothing ->
                model_


close : WindowId -> Model -> Model
close =
    let
        removeApp appId model =
            { model
                | apps = Dict.remove appId model.apps
                , windowOfApps = Dict.remove appId model.windowOfApps
            }

        removeWindow windowId model =
            { model
                | windows = Dict.remove windowId model.windows
                , sessionOfWindows = Dict.remove windowId model.sessionOfWindows
            }

        killApps window model =
            window
                |> listAppIds
                |> List.foldl removeApp model

        cleanSessions windowId model =
            let
                sessions =
                    Dict.map (always <| removeFromSession windowId)
                        model.sessions
            in
                { model | sessions = sessions }
    in
        \windowId model ->
            case getWindow windowId model of
                Just window ->
                    model
                        |> killApps window
                        |> cleanSessions windowId
                        |> removeWindow windowId
                        |> filterHiddenPinned windowId
                        |> filterVisiblePinned windowId

                Nothing ->
                    model


linkAppWindow : AppId -> WindowId -> Model -> Model
linkAppWindow appId windowId model =
    let
        windowOfApps =
            Dict.insert appId windowId model.windowOfApps
    in
        { model | windowOfApps = windowOfApps }


getWindowOfApp : AppId -> Model -> Maybe WindowId
getWindowOfApp appId =
    .windowOfApps >> Dict.get appId


linkWindowSession : WindowId -> CId -> Model -> Model
linkWindowSession windowId cid model =
    let
        sessionOfWindows =
            Dict.insert windowId cid model.sessionOfWindows
    in
        { model | sessionOfWindows = sessionOfWindows }


getSessionOfWindow : WindowId -> Model -> Maybe CId
getSessionOfWindow windowId =
    .sessionOfWindows >> Dict.get windowId


getDragging : Model -> Maybe WindowId
getDragging =
    .dragging


togglePin : WindowId -> Model -> Model
togglePin windowId ({ pinned } as model) =
    let
        member =
            List.member windowId
    in
        if member pinned.visible || member pinned.hidden then
            unpin windowId model
        else
            pin windowId model


pin : WindowId -> Model -> Model
pin windowId ({ pinned } as model) =
    let
        sessions =
            Dict.map (always <| restore windowId) model.sessions

        visible =
            pinned.visible
                |> List.reverse
                |> (::) windowId
                |> List.reverse

        pinned_ =
            { pinned | visible = visible }
    in
        { model | sessions = sessions, pinned = pinned_ }


unpin : WindowId -> Model -> Model
unpin windowId model =
    case getSessionOfWindow windowId model of
        Just cid ->
            let
                session =
                    getSession cid model

                sessions =
                    model.sessions
                        |> Dict.map (always <| removeFromSession windowId)
                        |> Dict.insert (cidToSessionId cid) session

                model_ =
                    { model | sessions = sessions }
            in
                filterVisiblePinned windowId model_

        Nothing ->
            close windowId model


insertVisiblePinned : WindowId -> Model -> Model
insertVisiblePinned windowId ({ pinned } as model) =
    let
        visible =
            pinned.visible
                |> List.reverse
                |> (::) windowId
                |> List.reverse

        pinned_ =
            { pinned | visible = visible }
    in
        { model | pinned = pinned_ }


filterHiddenPinned : WindowId -> Model -> Model
filterHiddenPinned windowId ({ pinned } as model) =
    let
        hidden =
            List.filter ((/=) windowId) pinned.hidden

        pinned_ =
            { pinned | hidden = hidden }
    in
        { model | pinned = pinned_ }


filterVisiblePinned : WindowId -> Model -> Model
filterVisiblePinned windowId ({ pinned } as model) =
    let
        visible =
            List.filter ((/=) windowId) pinned.visible

        pinned_ =
            { pinned | visible = visible }
    in
        { model | pinned = pinned_ }


minimizeAll : DesktopApp -> CId -> Model -> Model
minimizeAll desktopApp cid model =
    let
        session =
            getSession cid model

        toMinimize =
            List.filter (filterByWindowApp desktopApp model)
                session.visible
    in
        List.foldl (minimize cid) model toMinimize


closeAll : DesktopApp -> CId -> Model -> Model
closeAll desktopApp cid model =
    let
        session =
            getSession cid model

        filterer =
            filterByWindowApp desktopApp model

        toCloseVisible =
            List.filter filterer session.visible

        toCloseHidden =
            List.filter filterer session.hidden

        foldlClose =
            List.foldl close
    in
        toCloseVisible
            |> foldlClose model
            |> flip foldlClose toCloseHidden


listAppsOfType : DesktopApp -> Model -> List AppId
listAppsOfType desktopApp =
    .apps
        >> Dict.filter (always (getModel >> toDesktopApp >> (==) desktopApp))
        >> Dict.keys


findExistingAppId : DesktopApp -> CId -> Model -> Maybe AppId
findExistingAppId =
    let
        getSessionWindows cid model =
            case getSession cid model of
                { visible, hidden } ->
                    hidden ++ visible

        filterAppByCId cid model appId =
            model
                |> getApp appId
                |> Maybe.map (getAppCId >> (==) cid)
                |> Maybe.withDefault False
    in
        \desktopApp cid model ->
            model
                |> getSessionWindows cid
                |> List.filter (filterByWindowApp desktopApp model)
                |> List.filterMap (flip getWindow model)
                |> List.concatMap listAppIds
                |> List.filter (filterAppByCId cid model)
                |> List.head


openOrRestoreApp : DesktopApp -> CId -> Model -> ( Model, Bool )
openOrRestoreApp desktopApp cid model =
    let
        session =
            getSession cid model

        filterer =
            filterByWindowApp desktopApp model

        noVisible =
            session.visible
                |> List.filter filterer
                |> List.isEmpty

        hidden =
            List.filter filterer session.hidden

        anyHidden =
            hidden
                |> List.isEmpty
                |> not
    in
        if noVisible && anyHidden then
            hidden
                |> List.foldl restore session
                |> flip (insertSession cid) model
                |> flip (,) False
        else
            ( model, True )


linkEndpointApp : AppId -> WindowId -> Model -> Model
linkEndpointApp appId windowId model =
    case getWindow windowId model of
        Just window ->
            case getInstance window of
                Double context appId_ Nothing ->
                    window
                        |> setInstance (Double context appId_ <| Just appId)
                        |> flip (insertWindow windowId) model

                Double _ _ _ ->
                    model

                Single _ _ ->
                    model

        Nothing ->
            model


getNewWindowPosition : CId -> Model -> Position
getNewWindowPosition cid model =
    let
        maybePosition =
            model
                |> getSession cid
                |> getFocusing
                |> Maybe.andThen (flip getWindow model)
                |> Maybe.map getPosition
    in
        case maybePosition of
            Just { x, y } ->
                Position (x + 32) (y + 32)

            Nothing ->
                Position 32 (44 + 32)



-- affecting apps


getAppContext : App -> Context
getAppContext =
    .context


getAppCId : App -> CId
getAppCId =
    .cid


getModel : App -> AppModel
getModel =
    .model


setModel : AppModel -> App -> App
setModel appModel app =
    { app | model = appModel }


getTitle : AppModel -> String
getTitle model =
    case model of
        LogViewerModel model ->
            LogViewer.title model

        TaskManagerModel model ->
            TaskManager.title model

        BrowserModel model ->
            Browser.title model

        ExplorerModel model ->
            Explorer.title model

        DBAdminModel model ->
            DBAdmin.title model

        ConnManagerModel model ->
            ConnManager.title model

        BounceManagerModel model ->
            BounceManager.title model

        FinanceModel model ->
            Finance.title model

        HebampModel model ->
            Hebamp.title model

        CtrlPanelModel model ->
            CtrlPanel.title model

        ServersGearsModel model ->
            ServersGears.title model

        LocationPickerModel model ->
            LocationPicker.title model

        LanViewerModel model ->
            LanViewer.title model

        EmailModel model ->
            Email.title model

        BugModel model ->
            Bug.title model

        CalculatorModel model ->
            Calculator.title model

        BackFlixModel model ->
            BackFlix.title model

        FloatingHeadsModel model ->
            FloatingHeads.title model

        VirusPanelModel model ->
            VirusPanel.title model


toDesktopApp : AppModel -> DesktopApp
toDesktopApp model =
    case model of
        LogViewerModel _ ->
            DesktopApp.LogViewer

        TaskManagerModel _ ->
            DesktopApp.TaskManager

        BrowserModel _ ->
            DesktopApp.Browser

        ExplorerModel _ ->
            DesktopApp.Explorer

        DBAdminModel _ ->
            DesktopApp.DBAdmin

        ConnManagerModel _ ->
            DesktopApp.ConnManager

        BounceManagerModel _ ->
            DesktopApp.BounceManager

        FinanceModel _ ->
            DesktopApp.Finance

        HebampModel _ ->
            DesktopApp.Hebamp

        CtrlPanelModel _ ->
            DesktopApp.CtrlPanel

        ServersGearsModel _ ->
            DesktopApp.ServersGears

        LocationPickerModel _ ->
            DesktopApp.LocationPicker

        LanViewerModel _ ->
            DesktopApp.LanViewer

        EmailModel _ ->
            DesktopApp.Email

        BugModel _ ->
            DesktopApp.Bug

        CalculatorModel _ ->
            DesktopApp.Calculator

        BackFlixModel _ ->
            DesktopApp.BackFlix

        FloatingHeadsModel _ ->
            DesktopApp.FloatingHeads

        VirusPanelModel _ ->
            DesktopApp.VirusPanel


isDecorated : AppModel -> Bool
isDecorated app =
    case app of
        HebampModel _ ->
            False

        FloatingHeadsModel _ ->
            False

        _ ->
            True


isResizable : AppModel -> Bool
isResizable app =
    case app of
        EmailModel _ ->
            False

        HebampModel _ ->
            False

        _ ->
            True



-- affecting windows


getPosition : Window -> Position
getPosition =
    .position


setPosition : Float -> Float -> Window -> Window
setPosition x y window =
    { window | position = Position x y }


move : Float -> Float -> Window -> Window
move deltaX deltaY ({ position } as window) =
    let
        position_ =
            Position (position.x + deltaX) (position.y + deltaY)
    in
        { window | position = position_ }


smartMove : Model -> Float -> Float -> Window -> Window
smartMove { appSize } deltaX deltaY ({ size, position } as window) =
    -- Consider app's size when moving
    let
        position0 =
            wmFringe appSize size position

        position_ =
            Position (position0.x + deltaX) (position0.y + deltaY)
    in
        { window | position = position_ }


getSize : Window -> Size
getSize =
    .size


isMaximized : Window -> Bool
isMaximized =
    .maximized


toggleMaximize : Window -> Window
toggleMaximize window =
    { window | maximized = not window.maximized }


getContext : Window -> Context
getContext window =
    case getInstance window of
        Single context _ ->
            context

        Double context _ _ ->
            context


setContext : Context -> Window -> Window
setContext context window =
    case context of
        Gateway ->
            case getInstance window of
                Single _ _ ->
                    window

                Double _ appId maybeAppId ->
                    { window | instance = Double context appId maybeAppId }

        Endpoint ->
            case getInstance window of
                Single _ _ ->
                    window

                Double _ appId Nothing ->
                    window

                Double _ appId justAppId ->
                    { window | instance = Double context appId justAppId }


toggleContext : Window -> Window
toggleContext window =
    case getContext window of
        Gateway ->
            setContext Endpoint window

        Endpoint ->
            setContext Gateway window


getInstance : Window -> Instance
getInstance =
    .instance


setInstance : Instance -> Window -> Window
setInstance instance window =
    { window | instance = instance }


listAppIds : Window -> List AppId
listAppIds window =
    case getInstance window of
        Single _ appId ->
            [ appId ]

        Double _ appId1 (Just appId2) ->
            [ appId1, appId2 ]

        Double _ appId Nothing ->
            [ appId ]


getActiveAppId : Window -> AppId
getActiveAppId window =
    case getInstance window of
        Single _ appId ->
            appId

        Double Gateway appId maybeAppId ->
            appId

        Double Endpoint _ (Just appId) ->
            appId

        Double Endpoint _ Nothing ->
            Debug.crash "Impossible window state"


hasMultipleContext : Window -> Bool
hasMultipleContext window =
    case getInstance window of
        Single _ _ ->
            False

        Double _ _ Nothing ->
            False

        Double _ _ _ ->
            True


hasFlexibleContext : Window -> Bool
hasFlexibleContext window =
    case getInstance window of
        Single _ _ ->
            False

        Double _ _ _ ->
            True



-- affecting sessions


minimizeWindow : WindowId -> Session -> Session
minimizeWindow windowId =
    removeVisible windowId >> insertHidden windowId


restore : WindowId -> Session -> Session
restore windowId =
    removeHidden windowId >> insertVisible windowId


getFocusing : Session -> Maybe WindowId
getFocusing =
    .focusing


focusWindow : Maybe WindowId -> Session -> Session
focusWindow maybeWindowId session =
    case maybeWindowId of
        Just windowId ->
            restore windowId session

        Nothing ->
            unfocus session


unfocus : Session -> Session
unfocus session =
    { session | focusing = Nothing }


insertVisible : WindowId -> Session -> Session
insertVisible windowId session =
    let
        session_ =
            removeVisible windowId session

        visible =
            session_.visible
                |> List.reverse
                |> (::) windowId
                |> List.reverse
    in
        { session_ | visible = visible, focusing = Just windowId }


removeVisible : WindowId -> Session -> Session
removeVisible windowId session =
    { session | visible = List.filter ((/=) windowId) session.visible }


insertHidden : WindowId -> Session -> Session
insertHidden windowId session =
    let
        session_ =
            removeHidden windowId session

        hidden =
            session_.hidden
                |> List.reverse
                |> (::) windowId
                |> List.reverse
    in
        { session_ | hidden = hidden }


removeHidden : WindowId -> Session -> Session
removeHidden windowId session =
    { session | hidden = List.filter ((/=) windowId) session.hidden }


removeFromSession : WindowId -> Session -> Session
removeFromSession windowId =
    removeVisible windowId >> removeHidden windowId



-- sidebar


getSidebar : Model -> Sidebar.Model
getSidebar =
    .sidebar


setSidebar : Sidebar.Model -> Model -> Model
setSidebar sidebar model =
    { model | sidebar = sidebar }



-- dependencies


startDragging : WindowId -> CId -> Model -> Model
startDragging windowId cid model =
    let
        model_ =
            { model | dragging = Just windowId }

        session =
            model_
                |> getSession cid
                |> focusWindow (Just windowId)
    in
        insertSession cid session model_


stopDragging : Model -> Model
stopDragging model =
    { model | dragging = Nothing }



-- internals


filterByWindowApp : DesktopApp -> Model -> WindowId -> Bool
filterByWindowApp desktopApp model windowId =
    let
        maybeAppModel =
            model
                |> getWindow windowId
                |> Maybe.map getActiveAppId
                |> Maybe.andThen (flip getApp model)
                |> Maybe.map (getModel >> toDesktopApp)
    in
        case maybeAppModel of
            Just desktopApp_ ->
                desktopApp == desktopApp_

            Nothing ->
                False


cidToSessionId : CId -> SessionId
cidToSessionId cid =
    case cid of
        Servers.GatewayCId id ->
            "gateway_id::" ++ id

        Servers.EndpointCId ( nid, ip ) ->
            "endpoint_addr::" ++ nid ++ "::" ++ ip


getUuid : Model -> ( String, Model )
getUuid model =
    let
        ( uuid, seed ) =
            Random.step Uuid.uuidGenerator model.seed
    in
        ( Uuid.toString uuid, { model | seed = seed } )


wmFringe : Maybe Size -> Size -> Position -> Position
wmFringe appSize { width } ({ x, y } as originalPosition) =
    case appSize of
        Just appSize ->
            let
                x_ =
                    ((toFloat appSize.width) - 8)
                        |> min x
                        |> max (toFloat (8 - width))

                y_ =
                    ((toFloat appSize.height) - 8)
                        |> min y
                        |> max 0
            in
                Position x_ y_

        Nothing ->
            originalPosition
