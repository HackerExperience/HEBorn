module Apps.Browser.Messages exposing (..)

import Game.Web.Models exposing (Response)
import Game.Network.Types exposing (NIP)
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
    | Crack NIP


type TabMsg
    = UpdateAddress String
    | GoAddress String
    | GoPrevious
    | GoNext
    | PageMsg Page.Msg
    | Fetched Response
    | Login
    | LoginFailed
