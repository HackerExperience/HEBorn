module Apps.BackFlix.Messages exposing (Msg(..))

import Apps.BackFlix.Models exposing (MainTab)
import Apps.BackFlix.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | UpdateTextFilter String
    | GoTab MainTab
