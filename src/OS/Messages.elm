module OS.Messages exposing (Msg(..))

import OS.SessionManager.Messages as SessionManager
import OS.Menu.Messages as Menu


type Msg
    = SessionManagerMsg SessionManager.Msg
    | MenuMsg Menu.Msg
