module Apps.Hebamp.Messages exposing (Msg(..))

import Apps.Hebamp.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | TimeUpdate Float
    | Play
    | Pause
    | SetCurrentTime Float
