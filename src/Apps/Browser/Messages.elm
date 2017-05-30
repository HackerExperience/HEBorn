module Apps.Browser.Messages exposing (Msg(..))

import Events.Models
import Requests.Models
import Apps.Browser.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | UpdateAddress String
    | AddressEnter
    | GoPrevious
    | GoNext
