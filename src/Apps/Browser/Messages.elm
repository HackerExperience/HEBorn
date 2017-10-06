module Apps.Browser.Messages exposing (..)

import Game.Web.Types exposing (Response)
import Game.Network.Types as Network
import Apps.Browser.Menu.Messages as Menu
import Apps.Browser.Pages.Messages as Page


type Msg
    = MenuMsg Menu.Msg
      -- Inside tab actions
    | ActiveTabMsg TabMsg
    | SomeTabMsg Int TabMsg
      -- Browser actions
    | NewTabIn String
    | ChangeTab Int


type TabMsg
    = UpdateAddress String
    | GoAddress String
    | GoPrevious
    | GoNext
    | PageMsg Page.Msg
    | Fetched Response
    | Crack Network.NIP
    | AnyMap Network.NIP
    | Login Network.NIP String
    | LoginFailed
