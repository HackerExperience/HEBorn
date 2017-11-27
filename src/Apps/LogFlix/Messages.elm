module Apps.LogFlix.Messages exposing (Msg(..))

import Apps.LogFlix.Models exposing (MainTab)
import Apps.LogFlix.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | UpdateTextFilter String
    | GoTab MainTab
    | DummyNoOp
