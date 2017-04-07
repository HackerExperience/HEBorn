module OS.Dock.Messages exposing (Msg(..))


import OS.WindowManager.Messages


type Msg
    = ToWM OS.WindowManager.Messages.Msg
