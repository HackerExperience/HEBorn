module OS.SessionManager.WindowManager.Resources exposing (..)


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
