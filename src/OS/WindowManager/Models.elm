module OS.WindowManager.Models
    exposing
        ( Model
        , initialModel
        , Window
        , WindowID
        , Position
        , Windows
        , defaultSize
        , updateWindows
        , getWindow
        , openWindow
        , openOrRestoreWindow
        , closeWindow
        , closeAllWindows
        , getOpenWindows
        , filterAppWindows
        , updateWindowPosition
        , windowsFoldr
        , hasWindowOpen
        , toggleMaximizeWindow
        , minimizeWindow
        , minimizeAllWindows
        , bringFocus
        , switchContext
        , getContextText
        , WindowState(..)
        )

import Dict
import Uuid
import Random.Pcg exposing (Seed, step, initialSeed)
import Draggable
import Utils
import OS.WindowManager.Windows exposing (GameWindow(..))
import Apps.Context as Context exposing (ActiveContext(..))


type alias Model =
    { windows : Windows
    , seed : Seed
    , drag : Draggable.State WindowID
    , dragging : Maybe WindowID
    , focus : Maybe WindowID
    , highestZ : Int
    }


type alias WindowID =
    String


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
    = Open
    | Minimized


type alias Window =
    { id : WindowID
    , window : GameWindow
    , state : WindowState
    , position : Position
    , title : String
    , size : Size
    , maximized : Bool
    , context : ActiveContext
    }


type alias Windows =
    Dict.Dict WindowID Window


initialPosition : Int -> Position
initialPosition off =
    Position (toFloat (32 * off)) (44 + (toFloat (32 * off))) off



-- initialPosition: 44 is header height hardwritten


initialWindows : Dict.Dict WindowID Window
initialWindows =
    Dict.empty


defaultSize : Size
defaultSize =
    Size 600 400


initialModel : Model
initialModel =
    { windows = initialWindows
    , seed = initialSeed 42
    , drag = Draggable.init
    , dragging = Nothing
    , focus = Nothing
    , highestZ = 1
    }


newWindow : Model -> GameWindow -> ( Window, Seed )
newWindow model window =
    let
        ( id, seed ) =
            step Uuid.uuidGenerator model.seed

        window_ =
            { id = (Uuid.toString id)
            , window = window
            , state = Open
            , position = initialPosition (Dict.size model.windows)
            , title = "Sem titulo"
            , size = defaultSize
            , maximized = False
            , context = ContextGateway
            }
    in
        ( window_, seed )


filterAppMinimizedWindows : Windows -> GameWindow -> Windows
filterAppMinimizedWindows windows app =
    Dict.filter
        (\id oWindow ->
            ((oWindow.state == Minimized)
                && (oWindow.window == app)
            )
        )
        windows


unMinimizeAllWindow : Window -> GameWindow -> Window
unMinimizeAllWindow window app =
    if (window.window == app) then
        { window | state = Open }
    else
        window


openWindow : Model -> GameWindow -> ( Windows, Seed, WindowID )
openWindow model window =
    let
        ( window_, seed_ ) =
            newWindow model window

        windows_ =
            Dict.insert window_.id window_ model.windows
    in
        ( windows_, seed_, window_.id )


restoreAllWindow : Model -> GameWindow -> ( Windows, Seed, Maybe WindowID )
restoreAllWindow model window =
    ( Dict.map
        (\id oWindow -> (unMinimizeAllWindow oWindow window))
        model.windows
    , model.seed
    , Nothing
    )


restoreWindow : WindowID -> Model -> GameWindow -> ( Windows, Seed )
restoreWindow winId model window =
    ( (Dict.update winId
        (\w ->
            case w of
                Just w ->
                    Just { w | state = Open }

                Nothing ->
                    Nothing
        )
        model.windows
      )
    , model.seed
    )


openOrRestoreWindow : Model -> GameWindow -> ( Windows, Seed, Maybe WindowID )
openOrRestoreWindow model window =
    let
        minimizeds =
            (filterAppMinimizedWindows model.windows window)
    in
        if ((Dict.size minimizeds) > 1) then
            restoreAllWindow model window
        else
            let
                ( windows_, seed_, winId ) =
                    (case List.head (Dict.values minimizeds) of
                        Just oWindow ->
                            let
                                ( windows_t, seed_t ) =
                                    restoreWindow oWindow.id model window
                            in
                                ( windows_t, seed_t, oWindow.id )

                        Nothing ->
                            openWindow model window
                    )
            in
                ( windows_, seed_, Just winId )


closeWindow : Model -> WindowID -> Windows
closeWindow model id =
    Dict.remove id model.windows


getOpenWindows : Model -> Windows
getOpenWindows model =
    Dict.filter (\id window -> window.state == Open) model.windows


filterAppWindows : Windows -> GameWindow -> Windows
filterAppWindows windows app =
    Dict.filter (\id window -> window.window == app) windows


windowsFoldr : (comparable -> v -> a -> a) -> a -> Dict.Dict comparable v -> a
windowsFoldr fun acc windows =
    Dict.foldr (fun) acc windows


getWindow : Model -> WindowID -> Maybe Window
getWindow model id =
    Dict.get id model.windows


updateWindows : Model -> WindowID -> Window -> Windows
updateWindows model id window =
    Utils.safeUpdateDict model.windows id window


updateWindowPosition : Model -> ( Float, Float ) -> Windows
updateWindowPosition model delta =
    case model.dragging of
        Nothing ->
            model.windows

        Just id ->
            let
                windows_ =
                    case (getWindow model id) of
                        Nothing ->
                            model.windows

                        Just window ->
                            let
                                ( dx, dy ) =
                                    delta

                                x_ =
                                    window.position.x + dx

                                y_ =
                                    window.position.y + dy

                                position_ =
                                    Position x_ y_ window.position.z

                                window_ =
                                    { window | position = position_ }

                                windows_ =
                                    updateWindows model id window_
                            in
                                windows_
            in
                windows_


hasWindowOpen : Model -> GameWindow -> Bool
hasWindowOpen model window =
    let
        filter id w =
            w.state == Open && w.window == window

        open =
            Dict.filter filter model.windows
    in
        not (Dict.isEmpty open)


toggleMaximizeWindow : Model -> WindowID -> Windows
toggleMaximizeWindow model id =
    case (getWindow model id) of
        Nothing ->
            model.windows

        Just window ->
            let
                window_ =
                    { window | maximized = not window.maximized }

                windows_ =
                    updateWindows model id window_
            in
                windows_


minimizeWindow : Model -> WindowID -> Windows
minimizeWindow model id =
    case (getWindow model id) of
        Nothing ->
            model.windows

        Just window ->
            let
                window_ =
                    { window | state = Minimized }

                windows_ =
                    updateWindows model id window_
            in
                windows_


minimizeAllWindows : Windows -> GameWindow -> Windows
minimizeAllWindows windows app =
    Dict.map
        (\k v ->
            { v
                | state =
                    (if v.window == app then
                        Minimized
                     else
                        v.state
                    )
            }
        )
        windows


closeAllWindows : Windows -> GameWindow -> Windows
closeAllWindows windows app =
    Dict.filter
        (\k v -> v.window /= app)
        windows


bringFocus : Model -> Maybe WindowID -> Model
bringFocus model target =
    case (target) of
        Nothing ->
            { model | focus = Nothing }

        Just id ->
            case (getWindow model id) of
                Nothing ->
                    model

                Just window ->
                    let
                        incHighestZ =
                            model.highestZ + 1

                        position_ =
                            Position window.position.x window.position.y incHighestZ

                        window_ =
                            { window | position = position_ }

                        windows_ =
                            updateWindows model id window_
                    in
                        { model
                            | highestZ = incHighestZ
                            , windows = windows_
                            , focus = Just id
                        }


getContext : Window -> ActiveContext
getContext window =
    window.context


getContextText : ActiveContext -> String
getContextText context =
    case context of
        ContextGateway ->
            "Gateway"

        ContextEndpoint ->
            "Remote"


switchContext : Model -> WindowID -> Model
switchContext model id =
    case (getWindow model id) of
        Nothing ->
            model

        Just window ->
            let
                context_ =
                    case (getContext window) of
                        ContextGateway ->
                            ContextEndpoint

                        ContextEndpoint ->
                            ContextGateway

                window_ =
                    { window | context = context_ }

                windows_ =
                    updateWindows model id window_
            in
                { model | windows = windows_ }
