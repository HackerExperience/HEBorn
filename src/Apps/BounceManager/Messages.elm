module Apps.BounceManager.Messages exposing (Msg(..))

import Apps.BounceManager.Models exposing (MainTab)
import Apps.BounceManager.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | GoTab MainTab
