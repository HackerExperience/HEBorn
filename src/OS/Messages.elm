module OS.Messages exposing (Msg(..))

import OS.Header.Messages as Header
import OS.WindowManager.Messages as WindowManager
import OS.Toasts.Messages as Toasts


type Msg
    = HeaderMsg Header.Msg
    | WindowManagerMsg WindowManager.Msg
    | ToastsMsg Toasts.Msg
