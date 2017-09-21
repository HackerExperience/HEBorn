module Apps.Browser.Pages.CommonActions exposing (CommonActions(..))

import Game.Network.Types exposing (NIP)


type CommonActions
    = GoAddress String
    | NewTabIn String
    | Crack NIP
