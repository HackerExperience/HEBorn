module OS.Resources exposing (..)


type Class
    = Session
    | Header
    | Dock
    | Version
    | AutoHide
    | SGateway
    | SBounce
    | SEndpoint
    | Context
    | Selected
    | Logo
    | NAcc
    | NChat


type Id
    = Dashboard
    | DesktopVersion


prefix : String
prefix =
    "os"


notificationsNode : String
notificationsNode =
    "notifs"
