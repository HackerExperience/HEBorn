module OS.WindowManager.Messages exposing (..)


import OS.WindowManager.Windows exposing (GameWindow)
import OS.WindowManager.Models exposing (WindowID)


type Msg
    = OpenWindow GameWindow
    | CloseWindow WindowID
