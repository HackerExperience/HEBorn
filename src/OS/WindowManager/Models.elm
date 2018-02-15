module OS.WindowManager.Models exposing (..)

import Dict exposing (Dict)
import Draggable
import Random.Pcg as Random
import Uuid
import Utils.Maybe as Maybe
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
import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)
import Game.Meta.Types.Context exposing (Context(..))
import Game.Servers.Shared exposing (CId)
import OS.WindowManager.Shared exposing (..)


type alias Model =
    { apps : Apps
    , windows : Windows
    , sessions : Sessions
    , dragging : Maybe WindowId
    , lastPosition : Position
    , seed : Random.Seed
    , drag : Draggable.State WindowId
    }



-- apps


type alias Apps =
    Dict AppId App


type alias App =
    { windowId : WindowId
    , serverCId : CId
    , model : AppModel
    , context : Context
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



-- windows


type alias Windows =
    Dict WindowId Window


type alias Window =
    { position : Position
    , size : Size
    , maximized : IsMaximized
    , instance : Instance
    , originSessionId : SessionId
    }


type alias Position =
    { x : Float
    , y : Float
    }


type alias Size =
    { width : Float
    , height : Float
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
    }


type alias Index =
    List WindowId



-- initializers


initialModel : Model
initialModel =
    { apps = Dict.empty
    , windows = Dict.empty
    , sessions = Dict.empty
    , dragging = Nothing
    , lastPosition = Position 0 44
    , seed = Random.initialSeed 844121764423
    , drag = Draggable.init
    }


initialSession : Session
initialSession =
    { hidden = []
    , visible = []
    , focusing = Nothing
    }



-- integrations


getApp : AppId -> Model -> Maybe App
getApp appId =
    .apps >> Dict.get appId


getWindow : WindowId -> Model -> Maybe Window
getWindow windowId =
    .windows >> Dict.get windowId


getSession : SessionId -> Model -> Session
getSession sessionId model =
    case Dict.get sessionId model.sessions of
        Just session ->
            session

        Nothing ->
            initialSession


getDragging : Model -> Maybe WindowId
getDragging =
    .dragging


newAppId : Model -> ( Model, AppId )
newAppId =
    getUuid


newWindowId : Model -> ( Model, WindowId )
newWindowId =
    getUuid


insert : WindowId -> Window -> Model -> Model
insert windowId window model =
    let
        sessionId =
            window.originSessionId

        session =
            model
                |> getSession window.originSessionId
                |> updateFocus (Just windowId)
    in
        model
            |> insertWindow windowId window
            |> insertSession sessionId session


insertWindow : WindowId -> Window -> Model -> Model
insertWindow windowId window model =
    -- this is a dumb function use it to update existing windows
    { model | windows = Dict.insert windowId window model.windows }


insertApp : AppId -> App -> Model -> Model
insertApp appId app model =
    -- this is a dumb function use it to update existing apps
    { model | apps = Dict.insert appId app model.apps }


insertSession : SessionId -> Session -> Model -> Model
insertSession sessionId session model =
    -- this is a dumb function use it to update existing sessions
    { model | sessions = Dict.insert sessionId session model.sessions }


removeApp : AppId -> Model -> Model
removeApp appId model =
    { model | apps = Dict.remove appId model.apps }


close : WindowId -> Model -> Model
close windowId model =
    let
        killAppsFast { instance } =
            case instance of
                Single _ appId ->
                    removeApp appId model

                Double _ appId1 (Just appId2) ->
                    model
                        |> removeApp appId1
                        |> removeApp appId2

                Double _ appId _ ->
                    removeApp appId model

        killAppsSlow () =
            -- this code may not need to exist
            let
                apps =
                    Dict.filter (\_ app -> app.windowId /= windowId) model.apps
            in
                { model | apps = apps }

        model_ =
            case getWindow windowId model of
                Just window ->
                    killAppsFast window

                Nothing ->
                    killAppsSlow ()

        sessions =
            -- this is slow, it's a bottleneck of pinned windows
            Dict.map (\_ session -> unpin windowId session) model_.sessions

        windows =
            Dict.remove windowId model.windows
    in
        { model_ | sessions = sessions, windows = windows }


minimizeAll : DesktopApp -> SessionId -> Model -> Model
minimizeAll desktopApp sessionId model =
    let
        session =
            getSession sessionId model

        toMinimize =
            List.filter (filterByWindowApp desktopApp model)
                session.visible

        session_ =
            List.foldl minimize session toMinimize
    in
        insertSession sessionId session_ model


closeAll : DesktopApp -> SessionId -> Model -> Model
closeAll desktopApp sessionId model =
    let
        session =
            getSession sessionId model

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


listAppId : DesktopApp -> Model -> List AppId
listAppId desktopApp model =
    model.apps
        |> Dict.filter (always (getModel >> toDesktopApp >> (==) desktopApp))
        |> Dict.keys


getOpenedAppId : DesktopApp -> CId -> SessionId -> Model -> Maybe AppId
getOpenedAppId desktopApp cid sessionId model =
    let
        session =
            getSession sessionId model

        getWindowAppIds window =
            case getInstance window of
                Single _ appId ->
                    [ appId ]

                Double _ appId (Just otherAppId) ->
                    [ appId, otherAppId ]

                Double _ appId _ ->
                    [ appId ]

        filterAppByCId appId =
            case getApp appId model of
                Just app ->
                    cid == (getServerCId app)

                Nothing ->
                    False
    in
        session.hidden
            |> (++) session.visible
            |> List.filter (filterByWindowApp desktopApp model)
            |> List.filterMap (flip getWindow model)
            |> List.concatMap getWindowAppIds
            |> List.filter filterAppByCId
            |> List.head


openOrRestoreApp : DesktopApp -> SessionId -> Model -> ( Model, Bool )
openOrRestoreApp desktopApp sessionId model =
    let
        session =
            getSession sessionId model

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
                |> flip (insertSession sessionId) model
                |> flip (,) False
        else
            ( model, True )



-- app helpers


getModel : App -> AppModel
getModel =
    .model


setModel : AppModel -> App -> App
setModel appModel app =
    { app | model = appModel }


getWindowId : App -> WindowId
getWindowId =
    .windowId


getServerCId : App -> CId
getServerCId =
    .serverCId


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



-- window helpers


getPosition : Window -> Position
getPosition =
    .position


getSize : Window -> Size
getSize =
    .size


getInstance : Window -> Instance
getInstance =
    .instance


getContext : Window -> Context
getContext window =
    case getInstance window of
        Single context _ ->
            context

        Double context _ _ ->
            context


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


setContext : Context -> Window -> Window
setContext context window =
    case getInstance window of
        Single _ _ ->
            window

        Double _ appId maybeAppId ->
            { window | instance = Double context appId maybeAppId }


setInstance : Instance -> Window -> Window
setInstance instance window =
    { window | instance = instance }


hasMultipleContext : Window -> Bool
hasMultipleContext window =
    case getInstance window of
        Single _ _ ->
            False

        Double _ _ _ ->
            True


isMaximized : Window -> Bool
isMaximized =
    .maximized


isSession : SessionId -> Window -> Bool
isSession sessionId { originSessionId } =
    sessionId == originSessionId


toggleMaximize : Window -> Window
toggleMaximize window =
    { window | maximized = not window.maximized }


toggleContext : Window -> Window
toggleContext window =
    case getInstance window of
        Single _ _ ->
            window

        Double Gateway _ _ ->
            setContext Endpoint window

        Double Endpoint _ _ ->
            setContext Gateway window


move : Float -> Float -> Window -> Window
move deltaX deltaY ({ position } as window) =
    let
        position_ =
            Position (position.x + deltaX) (position.y + deltaY)
    in
        { window | position = position_ }



-- session helpers


getFocusing : Session -> Maybe WindowId
getFocusing =
    .focusing


pin : WindowId -> Session -> Session
pin =
    restore


unpin : WindowId -> Session -> Session
unpin windowId session =
    let
        filterer =
            (/=) >> List.filter

        visible =
            filterer windowId session.visible

        hidden =
            filterer windowId session.hidden
    in
        { session
            | visible = visible
            , hidden = hidden
            , focusing = List.head <| List.reverse visible
        }


minimize : WindowId -> Session -> Session
minimize windowId session =
    let
        filterer =
            (/=) >> List.filter

        visible =
            filterer windowId session.visible

        hidden =
            session.hidden
                |> filterer windowId
                |> (::) windowId
    in
        { session
            | visible = visible
            , hidden = hidden
            , focusing = List.head <| List.reverse visible
        }


restore : WindowId -> Session -> Session
restore windowId session =
    let
        filterer =
            (/=) >> List.filter

        visible =
            session.visible
                |> filterer windowId
                |> List.reverse
                |> (::) windowId
                |> List.reverse

        hidden =
            filterer windowId session.hidden
    in
        { session
            | visible = visible
            , hidden = hidden
            , focusing = Just windowId
        }


toggleVisibility : WindowId -> Session -> Session
toggleVisibility windowId session =
    if List.member windowId session.visible then
        minimize windowId session
    else
        restore windowId session


updateFocus : Maybe WindowId -> Session -> Session
updateFocus maybeWindowId session =
    case maybeWindowId of
        Just windowId ->
            restore windowId session

        Nothing ->
            { session | focusing = Nothing }



-- middleware


startDragging : WindowId -> SessionId -> Model -> Model
startDragging windowId sessionId model =
    let
        model_ =
            { model | dragging = Just windowId }

        session =
            model_
                |> getSession sessionId
                |> updateFocus (Just windowId)
    in
        insertSession sessionId session model_


stopDragging : Model -> Model
stopDragging model =
    { model | dragging = Nothing }



-- apps integrations


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



-- internals


getUuid : Model -> ( Model, String )
getUuid model =
    let
        ( uuid, seed ) =
            Random.step Uuid.uuidGenerator model.seed
    in
        ( { model | seed = seed }, Uuid.toString uuid )


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
