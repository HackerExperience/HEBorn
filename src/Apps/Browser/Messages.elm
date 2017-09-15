module Apps.Browser.Messages exposing (Msg(..))

import Game.Web.DNS exposing (Response)
import Apps.Browser.Menu.Messages as Menu


type Msg
    = MenuMsg Menu.Msg
    | UpdateAddress String
    | GoPrevious
    | GoNext
    | PageMsg
    | TabGo Int
    | GoAddress String
    | NewTabInAddress String
    | Fetched Int Response
