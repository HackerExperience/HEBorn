module OS.WindowManager.Resources exposing (..)


type Classes
    = Window
    | WindowHeader
    | WindowBody
    | Maximizeme
    | HeaderSuper
    | HeaderTitle
    | HeaderVoid
    | HeaderButtons
    | HeaderButton
    | HeaderBtnClose
    | HeaderBtnPin
    | HeaderBtnMaximize
    | HeaderBtnMinimize
    | HeaderContextSw
    | Canvas
    | Super


workspaceNode : String
workspaceNode =
    "workspace"


prefix : String
prefix =
    "wm"


decoratedAttrTag : String
decoratedAttrTag =
    "decorated"


appIconAttrTag : String
appIconAttrTag =
    "icon"
