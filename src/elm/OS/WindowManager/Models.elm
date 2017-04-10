module OS.WindowManager.Models
    exposing
        ( Model
        , initialModel
        , Window
        , WindowID
        , Position
        , defaultSize
        , openWindow
        , closeWindow
        , getOpenWindows
        , updateWindowPosition
        , windowsFoldr
        )

import Dict
import Uuid
import Random.Pcg exposing (Seed, step, initialSeed)
import Draggable
import OS.WindowManager.Windows exposing (GameWindow(..))
import OS.WindowManager.ContextHandler.Models as ContextHandler


type alias Model =
    { windows : Windows
    , seed : Seed
    , drag : Draggable.State WindowID
    , dragging : Maybe WindowID
    , contextHandler : ContextHandler.Model
    }


type alias WindowID =
    String


type alias Position =
    { x : Float
    , y : Float
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
    }


type alias Windows =
    Dict.Dict WindowID Window


initialPosition : Position
initialPosition =
    Position 32 32


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
    , contextHandler = ContextHandler.initialModel
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
            , position = initialPosition
            , title = "Sem titulo"
            , size = defaultSize
            }
    in
        ( window_, seed )


openWindow : Model -> GameWindow -> ( Windows, Seed )
openWindow model window =
    let
        ( window_, seed_ ) =
            newWindow model window

        windows_ =
            Dict.insert window_.id window_ model.windows
    in
        ( windows_, seed_ )


closeWindow : Model -> WindowID -> Windows
closeWindow model id =
    Dict.remove id model.windows


getOpenWindows : Model -> Windows
getOpenWindows model =
    let
        open =
            Dict.filter (\id window -> window.state == Open) model.windows
    in
        open


windowsFoldr : (comparable -> v -> a -> a) -> a -> Dict.Dict comparable v -> a
windowsFoldr fun acc windows =
    Dict.foldr (fun) acc windows


getWindow : Model -> WindowID -> Maybe Window
getWindow model id =
    Dict.get id model.windows



-- Help, make me pretty


updateWindowPosition : Model -> ( Float, Float ) -> Windows
updateWindowPosition model delta =
    let
        windows_ =
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
                                            Position x_ y_

                                        window_ =
                                            { window | position = position_ }

                                        update_ w =
                                            case w of
                                                Just window ->
                                                    Just window_

                                                Nothing ->
                                                    Nothing

                                        windows_ =
                                            Dict.update id update_ model.windows
                                    in
                                        windows_
                    in
                        windows_
    in
        windows_
