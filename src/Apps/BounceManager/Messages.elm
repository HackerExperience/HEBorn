module Apps.BounceManager.Messages exposing (Msg(..))

import Apps.BounceManager.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
