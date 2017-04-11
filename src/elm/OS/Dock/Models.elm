module OS.Dock.Models
    exposing
        ( Model
        , initialModel
        , Application
        , getApplications
        )

import OS.WindowManager.Windows exposing (GameWindow(..))


-- oi


type alias Application =
    { name : String
    , window : GameWindow
    , icon : Icon
    }


type alias Icon =
    { path : String
    }


type alias Dock =
    List Application


type alias Model =
    { dock : Dock
    }


generateIcon : String -> Icon
generateIcon name =
    let
        path =
            "icons/" ++ name ++ ".png"
    in
        { path = path }


generateApplication : GameWindow -> Application
generateApplication window =
    let
        name =
            case window of
                ExplorerWindow ->
                    "explorer"

        icon =
            generateIcon name
    in
        { name = name, window = window, icon = icon }


initialApplications : List Application
initialApplications =
    let
        applications =
            [ generateApplication ExplorerWindow ]
    in
        applications


initialDock : Dock
initialDock =
    initialApplications


initialModel : Model
initialModel =
    { dock = initialDock }


getApplications : Model -> Dock
getApplications model =
    model.dock
