module Game.Account.Dock.Models exposing (Model, initialModel)

import Game.Meta.Types.Apps.Desktop as DesktopApp exposing (DesktopApp)


type alias Model =
    List DesktopApp


initialModel : Model
initialModel =
    [ DesktopApp.Browser
    , DesktopApp.Explorer
    , DesktopApp.LogViewer
    , DesktopApp.TaskManager
    , DesktopApp.DBAdmin
    , DesktopApp.ConnManager
    , DesktopApp.BounceManager
    , DesktopApp.Finance
    , DesktopApp.Hebamp
    , DesktopApp.CtrlPanel
    , DesktopApp.ServersGears
    , DesktopApp.LanViewer
    , DesktopApp.Email
    , DesktopApp.Bug
    , DesktopApp.BackFlix
    , DesktopApp.Calculator
    ]
