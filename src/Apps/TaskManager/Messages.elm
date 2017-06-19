module Apps.TaskManager.Messages exposing (Msg(..))

import Time exposing (Time)
import Apps.TaskManager.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | Tick Time
