module OS.Header.Resources exposing (..)


type Class
    = Hidden
    | Header
    | SGateway
    | SBounce
    | Context
    | Network
    | SEndpoint
    | Taskbar
    | Selected
    | Notification
    | AccountIco
    | Connection
    | AvailableNetworks
    | ActiveNetwork
    | ReadOnly
    | BounceMenu
    | BounceMenuLeft
    | BounceMenuRight
    | BounceList
    | BounceListEntry
    | BounceMember
    | BounceMembers
    | BounceOptions
    | Empty
    | Logo
    | ChatIco
    | ServersIco


prefix : String
prefix =
    "hdr"


indicatorNode : String
indicatorNode =
    "indic"


bubbleNode : String
bubbleNode =
    "bubble"


headerContextActiveAttrTag : String
headerContextActiveAttrTag =
    "active"


expandedMenuAttrTag : String
expandedMenuAttrTag =
    "expanded"
