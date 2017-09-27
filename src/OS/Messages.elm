module OS.Messages exposing (Msg(..))

import OS.SessionManager.Messages as SessionManager
import OS.Header.Messages as Header
import OS.Menu.Messages as Menu
import OS.Toasts.Messages as Toasts
import Events.Events as Events


type Msg
    = SessionManagerMsg SessionManager.Msg
    | HeaderMsg Header.Msg
    | MenuMsg Menu.Msg
    | ToastsMsg Toasts.Msg
    | Event Events.Event
