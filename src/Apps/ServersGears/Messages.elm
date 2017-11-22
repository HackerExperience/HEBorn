module Apps.ServersGears.Messages exposing (Msg(..))

import Apps.ServersGears.Menu.Messages as Menu
import Apps.ServersGears.Models exposing (..)


type Msg
    = MenuMsg Menu.Msg
    | Select Selection
