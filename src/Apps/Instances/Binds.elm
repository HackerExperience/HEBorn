module Apps.Instances.Binds exposing (open, close, context)

import OS.WindowManager.Windows exposing (GameWindow(..))
import Apps.Explorer.Messages as Explorer


open window msg =
    case window of
        ExplorerWindow ->
            Explorer.OpenInstance msg


close window msg =
    case window of
        ExplorerWindow ->
            Explorer.CloseInstance msg


context window msg =
    case window of
        ExplorerWindow ->
            Explorer.SwitchContext msg
