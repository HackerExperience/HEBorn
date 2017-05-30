module OS.Dock.Models
    exposing
        ( Model
        , initialModel
        , Application
        , getApplications
        , updateInstances
        )

import Dict
import OS.WindowManager.Models exposing (Windows, WindowID, WindowState(..), filterAppWindows)
import Apps.Models as Apps


type alias Application =
    { app : Apps.App
    , instancesNum : Int
    , openWindows : List WindowID
    , minimizedWindows : List WindowID
    }


type alias Dock =
    List Application


type alias Model =
    { dock : Dock
    }


generateApplication : Apps.App -> Application
generateApplication app =
    { app = app, instancesNum = 0, openWindows = [], minimizedWindows = [] }


initialApplications : List Application
initialApplications =
    List.map generateApplication
        [ Apps.TaskManagerApp
        , Apps.BrowserApp
        , Apps.ExplorerApp
        , Apps.LogViewerApp
        ]


refreshInstances : Windows -> Application -> Application
refreshInstances windows application =
    -- REVIEW: Why not use "Instances" for this?
    let
        appWindows =
            filterAppWindows application.app windows

        minimizeds =
            Dict.filter
                (\id oWindow -> (oWindow.state == MinimizedState))
                appWindows

        openeds =
            Dict.filter
                (\id oWindow -> (oWindow.state == NormalState))
                appWindows
    in
        { application
            | instancesNum = (Dict.size appWindows)
            , openWindows = (Dict.keys openeds)
            , minimizedWindows = (Dict.keys minimizeds)
        }


updateInstances : Model -> Windows -> Model
updateInstances model windows =
    { model | dock = List.map (refreshInstances windows) model.dock }


initialDock : Dock
initialDock =
    initialApplications


initialModel : Model
initialModel =
    { dock = initialDock }


getApplications : Model -> Dock
getApplications model =
    model.dock
