module Apps.Finance.Messages exposing (Msg(..))

import Apps.Finance.Models exposing (MainTab)
import Apps.Finance.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | GoTab MainTab
