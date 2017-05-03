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
import OS.WindowManager.Models exposing (Windows, WindowID, filterAppWindows, WindowState(..))


type alias Application =
    { name : String
    , window : GameWindow
    , icon : String
    , instancesNum : Int
    , openWindows : List WindowID
    , minimizedWindows : List WindowID
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

        icon =
            name
    in
        { name = name, window = window, icon = icon, instancesNum = 0, openWindows = [], minimizedWindows = [] }


initialApplications : List Application
initialApplications =
    let
        applications =
            [ generateApplication ExplorerWindow
            , generateApplication LogViewerWindow
            ]
    in
        applications


refreshInstances : Windows -> Application -> Application
refreshInstances windows app =
    -- REVIEW: Why not use "Instances" for this?
    let
        appWindows =
            filterAppWindows windows app.window

        minimizeds =
            Dict.filter
                (\id oWindow -> (oWindow.state == Minimized))
                appWindows

        openeds =
            Dict.filter
                (\id oWindow -> (oWindow.state == Open))
                appWindows
    in
        { app
            | instancesNum = (Dict.size appWindows)
            , openWindows = (Dict.keys openeds)
            , minimizedWindows = (Dict.keys minimizeds)
        }


updateInstances : Model -> Windows -> Model
updateInstances model windows =
    { model | dock = (List.map (\app -> (refreshInstances windows app)) model.dock) }


initialDock : Dock
initialDock =
    initialApplications


initialModel : Model
initialModel =
    { dock = initialDock }


getApplications : Model -> Dock
getApplications model =
    model.dock
