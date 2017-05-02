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
        , closeWindow
        , getOpenWindows
        , filterAppWindows
        , updateWindowPosition
        , windowsFoldr
        , hasWindowOpen
        , toggleMaximizeWindow
        , minimizeWindow
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


unMinimizeIfGameWindow : Window -> GameWindow -> Window
unMinimizeIfGameWindow window app =
    if (window.window == app) then
        { window | state = Open }
    else
        window


openWindow : Model -> GameWindow -> ( Windows, Seed, Maybe WindowID )
openWindow model window =
    let
        minimizeds =
            (filterAppMinimizedWindows model.windows window)

        countMin =
            (Dict.size minimizeds)

        unminimizeOrCreate =
            if (countMin > 1) then
                ( Dict.map
                    (\id oWindow -> (unMinimizeIfGameWindow oWindow window))
                    model.windows
                , model.seed
                , Nothing
                )
            else if (countMin == 1) then
                let
                    pWindow =
                        List.head (Dict.values minimizeds)

                    safeResult =
                        case pWindow of
                            Just oWindow ->
                                let
                                    mWindow w =
                                        case w of
                                            Just w ->
                                                Just { oWindow | state = Open }

                                            Nothing ->
                                                Nothing

                                    id =
                                        oWindow.id
                                in
                                    ( (Dict.update id mWindow model.windows)
                                    , model.seed
                                    , Just id
                                    )

                            Nothing ->
                                ( model.windows, model.seed, Nothing )
                in
                    safeResult
            else
                let
                    ( rNewWindow, newSeed ) =
                        newWindow model window
                in
                    ( Dict.insert rNewWindow.id rNewWindow model.windows
                    , newSeed
                    , Just rNewWindow.id
                    )
    in
        unminimizeOrCreate


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
