module OS.Messages exposing (Msg(..))

import OS.Header.Messages as Header
import OS.Map.Messages as Map
import OS.WindowManager.Messages as WindowManager
import OS.Toasts.Messages as Toasts


type Msg
    = HeaderMsg Header.Msg
    | MapMsg Map.Msg
    | WindowManagerMsg WindowManager.Msg
    | ToastsMsg Toasts.Msg
