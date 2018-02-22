module Game.Meta.Types.Apps.Desktop exposing (..)


type DesktopApp
    = BackFlix
    | BounceManager
    | Browser
    | Bug
    | Calculator
    | ConnManager
    | CtrlPanel
    | DBAdmin
    | Email
    | Explorer
    | Finance
    | FloatingHeads
    | Hebamp
    | LanViewer
    | LocationPicker
    | LogViewer
    | ServersGears
    | TaskManager
    | VirusPanel


type alias Reference =
    String


type alias BrowserTab =
    Int


type alias Requester =
    { reference : Reference
    , browserTab : BrowserTab
    }
