module Apps.Browser.Pages.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.Webserver.Messages as Webserver
import Apps.Browser.Pages.DownloadCenter.Messages as DownloadCenter
import Apps.Browser.Pages.Bank.Messages as Bank


type Msg
    = WebserverMsg Webserver.Msg
    | BankMsg Bank.Msg
    | DownloadCenterMsg DownloadCenter.Msg
    | GlobalMsg CommonActions
    | Ignore
