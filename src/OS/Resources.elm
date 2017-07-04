module OS.Resources exposing (..)


type Classes
    = Session
    | Header
    | Dock
    | Version


type Id
    = Dashboard
    | DesktopVersion


prefix : String
prefix =
    "os"
