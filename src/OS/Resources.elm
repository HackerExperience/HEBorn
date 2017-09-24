module OS.Resources exposing (..)


type Class
    = Session
    | Header
    | Dock
    | Version
    | AutoHide
    | Connection
    | Taskbar
    | SGateway
    | SBounce
    | SEndpoint
    | Context
    | Selected
    | Logo
    | ChatIco
    | ServersIco
    | Notification
    | Account
    | Empty
    | Toasts
    | Fading


type Id
    = Dashboard
    | DesktopVersion


prefix : String
prefix =
    "os"


indicatorNode : String
indicatorNode =
    "indic"


bubbleNode : String
bubbleNode =
    "bubble"
