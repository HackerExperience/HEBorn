module OS.Dock.Models
    exposing
        ( Model
        , initialModel
        , Application
        , getApplications
        , updateInstances
        )

import Dict
import OS.WindowManager.Windows exposing (GameWindow(..))
import OS.WindowManager.Models exposing (Windows, filterAppWindows)


type alias Application =
    { name : String
    , window : GameWindow
    , icon : String
    , instancesNum : Int
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

                LogViewerWindow ->
                    "logvw"

                BrowserWindow ->
                    "browser"

        icon =
            name
    in
        { name = name, window = window, icon = icon, instancesNum = 0 }


initialApplications : List Application
initialApplications =
    let
        applications =
            [ generateApplication ExplorerWindow
            , generateApplication LogViewerWindow
            , generateApplication BrowserWindow
            ]
    in
        applications


recountInstances : Windows -> Application -> Application
recountInstances windows app =
    { app | instancesNum = (Dict.size (filterAppWindows windows app.window)) }


updateInstances : Model -> Windows -> Model
updateInstances model windows =
    { model | dock = (List.map (\app -> (recountInstances windows app)) model.dock) }


initialDock : Dock
initialDock =
    initialApplications


initialModel : Model
initialModel =
    { dock = initialDock }


getApplications : Model -> Dock
getApplications model =
    model.dock
