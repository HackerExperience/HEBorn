module Apps.Browser.Pages.Messages exposing (Msg(..))

import Apps.Browser.Pages.CommonActions exposing (..)
import Apps.Browser.Pages.NoWebserver.Messages as NoWebserver
import Apps.Browser.Pages.DownloadCenter.Messages as DownloadCenter
import Apps.Browser.Pages.Bank.Messages as Bank


type Msg
    = NoWebserverMsg NoWebserver.Msg
    | BankMsg Bank.Msg
    | DownloadCenterMsg DownloadCenter.Msg
    | GlobalMsg CommonActions
    | Ignore
