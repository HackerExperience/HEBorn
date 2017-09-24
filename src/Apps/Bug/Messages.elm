module Apps.Bug.Messages exposing (Msg(..))

import Apps.Bug.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | DummyToast
