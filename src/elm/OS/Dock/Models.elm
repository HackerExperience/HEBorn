module OS.Dock.Models exposing ( Model, initialModel
                               , Application
                               , getApplications)


import OS.WindowManager.Windows exposing (GameWindow(..))



type alias Application =
    { name : String
    , window : GameWindow
    , icon : Icon
    }


type alias Icon =
    { path: String
    }


type alias Dock =
    List Application


type alias Model =
    { dock : Dock
    }


generateIcon name =
    let
        path = "icons/" ++ name ++ ".png"
    in
        {path = path}


generateApplication window =
    let
        name =
            case window of
                SignUpWindow ->
                    "signup"
                ExplorerWindow ->
                    "explorer"
        icon = generateIcon name
    in
        {name = name, window = window, icon = icon}


initialApplications =
    let
        applications = [generateApplication SignUpWindow]
                       ++ [generateApplication ExplorerWindow]
    in
        applications


initialDock =
    initialApplications


initialModel =
    { dock = initialDock }


getApplications model =
    model.dock
