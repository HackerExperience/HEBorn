module OS.Resources exposing (..)


type Class
    = Session
    | Dock
    | Version
    | AutoHide


type Id
    = Dashboard
    | DesktopVersion


prefix : String
prefix =
    "os"


gameVersionAttrTag : String
gameVersionAttrTag =
    "game-version"


devVersion : String
devVersion =
    "dev"


gameModeAttrTag : String
gameModeAttrTag =
    "game-mode"


campaignMode : String
campaignMode =
    "campaign"


multiplayerMode : String
multiplayerMode =
    "multiplayer"
