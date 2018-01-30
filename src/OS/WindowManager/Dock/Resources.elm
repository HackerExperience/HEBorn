module OS.WindowManager.Dock.Resources exposing (..)


type Classes
    = Item
    | ItemIco
    | Main
    | Container
    | AppContext
    | Visible
    | ClickableWindow


prefix : String
prefix =
    "dock"


appIconAttrTag : String
appIconAttrTag =
    "icon"


appHasInstanceAttrTag : String
appHasInstanceAttrTag =
    "hasinst"
