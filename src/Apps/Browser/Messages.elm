module Apps.Browser.Messages exposing (..)

import Game.Web.DNS exposing (Response)
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
    | Crack String


type TabMsg
    = UpdateAddress String
    | GoAddress String
    | GoPrevious
    | GoNext
    | PageMsg Page.Msg
    | Fetched Response
