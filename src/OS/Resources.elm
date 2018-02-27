module OS.Resources exposing (..)


type Class
    = Session
    | Header
    | Dock
    | Version
    | AutoHide
    | Connection
    | Taskbar
    | Network
    | AvailableNetworks
    | ActiveNetwork
    | SGateway
    | SBounce
    | SEndpoint
    | Context
    | Selected
    | Logo
    | ChatIco
    | ServersIco
    | Notification
    | AccountIco
    | Empty
    | Toasts
    | Fading
    | Hidden
    | ReadOnly
    | BounceMenu
    | BounceMenuLeft
    | BounceMenuRight
    | BounceList
    | BounceListEntry
    | BounceMember
    | BounceMembers
    | BounceOptions
    | LogConsole
    | LogConsoleBox
    | LogConsoleHeader
    | LogConsoleDataDiv
    | BFRequest
    | BFReceive
    | BFJoin
    | BFJoinAccount
    | BFJoinServer
    | BFNone
    | BFOther
    | BFEvent
    | BFError


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


headerContextActiveAttrTag : String
headerContextActiveAttrTag =
    "active"


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


expandedMenuAttrTag : String
expandedMenuAttrTag =
    "expanded"
