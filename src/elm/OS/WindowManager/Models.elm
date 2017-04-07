module OS.WindowManager.Models exposing ( Model, initialModel
                                        , Window, WindowID
                                        , openWindow, closeWindow
                                        , getOpenWindows
                                        , windowsFoldr)


import Dict

import Uuid
import Random.Pcg exposing (Seed, step, initialSeed)
import OS.WindowManager.Windows exposing (GameWindow(..))


type alias Model =
    { windows : Windows
    , seed : Seed}


type alias WindowID =
    String


type WindowState
    = Open
    | Minimized


type alias Window =
    { id : WindowID
    , window : GameWindow
    , state : WindowState}


type alias Windows =
    Dict.Dict WindowID Window


initialWindows : Dict.Dict WindowID Window
initialWindows =
    Dict.empty


initialModel : Model
initialModel =
    { windows = initialWindows
    , seed = initialSeed 42}


newWindow : Model -> GameWindow -> (Window, Seed)
newWindow model window =
    let
        (id, seed) = step Uuid.uuidGenerator model.seed
        window_ =
            { id = (Uuid.toString id)
            , window = window
            , state = Open}
    in
        (window_, seed)


openWindow : Model -> GameWindow -> (Windows, Seed)
openWindow model window =
    let
        (window_, seed_) = newWindow model window
        windows_ = Dict.insert window_.id window_ model.windows
    in
        (windows_, seed_)


closeWindow : Model -> WindowID -> Windows
closeWindow model id =
  Dict.remove id model.windows


getOpenWindows : Model -> Windows
getOpenWindows model =
    let
        open = Dict.filter (\id window -> window.state == Open) model.windows
    in
        open


-- windowsMap : a -> Windows
windowsMap fun windows =
    Dict.map fun windows

windowsFoldr fun acc windows =
    Dict.foldr (fun) acc windows
