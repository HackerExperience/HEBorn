module Apps.Explorer.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Apps.Explorer.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
