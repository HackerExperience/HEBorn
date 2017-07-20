module Apps.Browser.Messages exposing (Msg(..))

import Apps.Browser.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | UpdateAddress String
    | AddressEnter
    | GoPrevious
    | GoNext
    | PageMsg
    | TabGo Int
