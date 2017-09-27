module Apps.Browser.Pages.CommonActions exposing (CommonActions(..))

import Game.Servers.Shared as Servers
import Game.Network.Types exposing (NIP)


type CommonActions
    = GoAddress String
    | NewTabIn String
    | Crack NIP
    | AnyMap NIP
    | Login NIP String
