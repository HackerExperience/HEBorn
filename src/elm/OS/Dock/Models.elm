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
    , icon : String
    }


type alias Dock =
    List Application


type alias Model =
    { dock : Dock
    }


generateApplication : GameWindow -> Application
generateApplication window =
    let
        name =
            case window of
                ExplorerWindow ->
                    "explorer"

        icon =
            name
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
