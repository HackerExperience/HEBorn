module OS.Dock.Messages exposing (Msg(..))

import OS.WindowManager.Messages
import OS.WindowManager.Models exposing (Windows)


type Msg
    = ToWM OS.WindowManager.Messages.Msg
    | WindowsChanges Windows
