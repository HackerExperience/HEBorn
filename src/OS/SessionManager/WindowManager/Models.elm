module OS.SessionManager.WindowManager.Models
    exposing
        ( Model
        , Windows
        , Window
        , Position
        , Size
        , WindowState(..)
        , WindowInstance(..)
        , WindowID
        , initialModel
        , openWindow
        , closeWindow
        , closeAppWindows
        , restoreWindow
        , restoreAppWindows
        , minimizeWindow
        , minimizeAppWindows
        , toggleWindowMaximization
        , unfocusWindow
        , focusWindow
        , openOrRestoreWindow
        , filterMinimizedAppWindows
        , filterOpenedWindows
        , filterAppWindows
        , foldlWindows
        , toggleWindowContext
        , updateWindow
        , updateWindowPosition
        , updateWindowSize
        , updateAppModel
        , getWindow
        , setWindow
        , getContext
        , getAppModel
        , startDragging
        , stopDragging
        )

import Uuid
import Draggable
import Maybe exposing (Maybe)
import Apps.Models as Apps
import Dict exposing (Dict)
import Random.Pcg exposing (Seed, step, initialSeed)
import OS.SessionManager.WindowManager.Context exposing (..)


type alias Position =
    { x : Float
    , y : Float
    , z : Int
    }


type alias Size =
    { width : Float
    , height : Float
    }


type WindowState
    = NormalState
    | MinimizedState


type WindowInstance
    = TogglableInstance Apps.AppModel Apps.AppModel
    | FixedInstance Apps.AppModel


type alias Window =
    { position : Position
    , size : Size
    , state : WindowState
    , maximized : Bool
    , app : Apps.App
    , context : Context
    , instance : WindowInstance
    }


type alias WindowID =
    String


type alias Windows =
    Dict WindowID Window


type alias Model =
    { windows : Windows
    , seed : Seed
    , drag : Draggable.State WindowID
    , dragging : Maybe WindowID
    , focus : Maybe WindowID
    , highestZ : Int
    }


defaultSize : Size
defaultSize =
    Size 600 400


initialPosition : Int -> Position
initialPosition off =
    Position (toFloat (32 * off)) (44 + (toFloat (32 * off))) off


initialWindows : Windows
initialWindows =
    Dict.empty


initialModel : Seed -> Model
initialModel seed =
    { windows = initialWindows
    , seed = seed
    , drag = Draggable.init
    , dragging = Nothing
    , focus = Nothing
    , highestZ = 1
    }


openWindow : Apps.App -> Model -> Model
openWindow app ({ seed, windows } as model) =
    let
        ( uuid, seed_ ) =
            step Uuid.uuidGenerator seed

        windowID =
            Uuid.toString uuid

        context =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    GatewayContext

                Apps.ContextlessApp ->
                    NoContext

        instance =
            case Apps.contexts app of
                Apps.ContextualApp ->
                    TogglableInstance (Apps.model app) (Apps.model app)

                Apps.ContextlessApp ->
                    FixedInstance (Apps.model app)

        window =
            Window
                (initialPosition (Dict.size model.windows))
                defaultSize
                NormalState
                False
                app
                context
                instance

        windows_ =
            Dict.insert windowID window windows
    in
        focusWindow windowID { model | windows = windows_, seed = seed_ }


closeWindow : WindowID -> Model -> Model
closeWindow windowID ({ windows } as model) =
    let
        windows_ =
            Dict.remove windowID windows
    in
        { model | windows = windows_ }


closeAppWindows : Apps.App -> Model -> Model
closeAppWindows app ({ windows } as model) =
    let
        windows_ =
            Dict.filter (\id win -> app /= win.app) windows
    in
        { model | windows = windows_ }


restoreWindow : WindowID -> Model -> Model
restoreWindow windowID ({ windows } as model) =
    lift restore windowID model


restoreAppWindows : Apps.App -> Model -> Model
restoreAppWindows app ({ windows } as model) =
    { model | windows = map (mapApp restore app) windows }


minimizeWindow : WindowID -> Model -> Model
minimizeWindow windowID ({ windows } as model) =
    lift minimize windowID model


minimizeAppWindows : Apps.App -> Model -> Model
minimizeAppWindows app ({ windows } as model) =
    { model | windows = map (mapApp minimize app) windows }


toggleWindowMaximization : WindowID -> Model -> Model
toggleWindowMaximization windowID ({ windows } as model) =
    lift toggleMaximize windowID model


unfocusWindow : Model -> Model
unfocusWindow model =
    { model | focus = Nothing, dragging = Nothing }


focusWindow : WindowID -> Model -> Model
focusWindow windowID ({ windows, highestZ } as model) =
    let
        highestZ_ =
            highestZ + 1

        model_ =
            lift
                (\window ->
                    move
                        window.position.x
                        window.position.y
                        highestZ_
                        window
                )
                windowID
                model
    in
        { model_ | highestZ = highestZ_ }


openOrRestoreWindow : Apps.App -> Model -> Model
openOrRestoreWindow app model =
    -- this could be better optimized
    let
        minimizedCount =
            Dict.size (filterMinimizedAppWindows app model)
    in
        if (minimizedCount == 0) then
            openWindow app model
        else
            restoreAppWindows app model


{-| we really need a filterMinimized |> groupByApp
-}
filterMinimizedAppWindows : Apps.App -> Model -> Windows
filterMinimizedAppWindows app { windows } =
    filter
        (\window -> window.state == MinimizedState && window.app == app)
        windows


filterOpenedWindows : Model -> Windows
filterOpenedWindows { windows } =
    filter (\window -> window.state == NormalState) windows


{-| we really need a groupByApp
-}
filterAppWindows : Apps.App -> Windows -> Windows
filterAppWindows app windows =
    filter (\window -> window.app == app) windows


foldlWindows : (WindowID -> Window -> a -> a) -> a -> Windows -> a
foldlWindows fold init windows =
    Dict.foldl fold init windows


toggleWindowContext : WindowID -> Model -> Model
toggleWindowContext windowID model =
    lift (toggleContext) windowID model


updateWindow : WindowID -> Window -> Model -> Model
updateWindow windowID window model =
    lift (always window) windowID model


updateWindowPosition : ( Float, Float ) -> Model -> Model
updateWindowPosition ( dx, dy ) model =
    case model.dragging of
        Nothing ->
            model

        Just windowID ->
            lift
                (\window ->
                    move
                        (window.position.x + dx)
                        (window.position.y + dy)
                        window.position.z
                        window
                )
                windowID
                model


updateWindowSize : Float -> Float -> Int -> WindowID -> Model -> Model
updateWindowSize x y z windowID model =
    lift (move x y z) windowID model


updateAppModel : WindowID -> Apps.AppModel -> Model -> Model
updateAppModel windowID appModel ({ windows } as model) =
    case Dict.get windowID windows of
        Just ({ instance } as window) ->
            let
                instance_ =
                    case window.instance of
                        TogglableInstance _ model ->
                            TogglableInstance appModel model

                        FixedInstance _ ->
                            FixedInstance appModel

                window_ =
                    { window | instance = instance_ }

                windows_ =
                    Dict.insert windowID window_ windows
            in
                { model | windows = windows_ }

        Nothing ->
            model


getWindow : WindowID -> Model -> Maybe Window
getWindow windowId { windows } =
    Dict.get windowId windows


setWindow : WindowID -> Window -> Model -> Model
setWindow windowId window ({ windows } as model) =
    let
        windows_ =
            Dict.insert windowId window windows
    in
        { model | windows = windows_ }


getContext : Window -> Context
getContext window =
    window.context


getAppModel : Window -> Apps.AppModel
getAppModel window =
    case window.instance of
        TogglableInstance model _ ->
            model

        FixedInstance model ->
            model


startDragging : WindowID -> Model -> Model
startDragging id model =
    { model | dragging = Just id }


stopDragging : Model -> Model
stopDragging model =
    { model | dragging = Nothing }



-- internals


lift : (Window -> Window) -> WindowID -> Model -> Model
lift fun windowID ({ windows } as model) =
    let
        windows_ =
            windows
                |> Dict.get windowID
                |> Maybe.map
                    (\instance ->
                        Dict.insert windowID (fun instance) windows
                    )
                |> Maybe.withDefault windows
    in
        { model | windows = windows_ }


map : (Window -> Window) -> Windows -> Windows
map func =
    Dict.map (\id window -> func window)


filter : (Window -> Bool) -> Windows -> Windows
filter func =
    Dict.filter (\id window -> func window)


move : Float -> Float -> Int -> Window -> Window
move x y z ({ position } as window) =
    let
        position_ =
            { position | x = x, y = y, z = z }
    in
        { window | position = position_ }


resize : Float -> Float -> Window -> Window
resize width height ({ size } as window) =
    let
        size_ =
            { size | width = width, height = height }
    in
        { window | size = size_ }


restore : Window -> Window
restore window =
    { window | state = NormalState }


minimize : Window -> Window
minimize window =
    { window | state = MinimizedState }


toggleMaximize : Window -> Window
toggleMaximize ({ maximized } as window) =
    { window | maximized = (not maximized) }


toggleContext : Window -> Window
toggleContext ({ context, instance } as window) =
    case instance of
        TogglableInstance modelA modelB ->
            let
                instance_ =
                    TogglableInstance modelB modelA

                context_ =
                    case context of
                        GatewayContext ->
                            EndpointContext

                        EndpointContext ->
                            GatewayContext

                        NoContext ->
                            NoContext
            in
                { window | instance = instance_, context = context_ }

        FixedInstance model ->
            window



-- this could also be replaced when starting to use groupBy


mapApp : (Window -> Window) -> Apps.App -> Window -> Window
mapApp fun app win =
    if win.app == app then
        fun win
    else
        win
