module OS.Dock.Messages exposing (Msg(..))

import OS.WindowManager.Models exposing (Windows)


type Msg
    = WindowsChanges Windows
