module Apps.Browser.Pages.Configs exposing (..)

import Game.Account.Finances.Models exposing (BankLoginRequest, BankTransferRequest)
import Apps.Browser.Config as Browser
import Apps.Browser.Pages.Bank.Config as Bank
import Apps.Browser.Pages.DownloadCenter.Config as DownloadCenter
import Apps.Browser.Pages.Home.Config as Home
import Apps.Browser.Pages.Webserver.Config as Webserver
import Apps.Browser.Messages exposing (..)


bankConfig : Bank.Config Msg
bankConfig =
    { toMsg = BankMsg >> ActiveTabMsg
    , onLogin = \a -> BankLogin a
    , onTransfer = \a -> BankTransfer a
    , onLogout = BankLogout
    }


downloadCenterConfig : Browser.Config msg -> DownloadCenter.Config Msg
downloadCenterConfig { endpoints } =
    { toMsg = DownloadCenterMsg >> ActiveTabMsg
    , onLogin = \a b -> ActiveTabMsg <| Login a b
    , onLogout = ActiveTabMsg Logout
    , onCrack = Crack >> ActiveTabMsg
    , onAnyMap = AnyMap >> ActiveTabMsg
    , onPublicDownload = PublicDownload
    , onSelectEndpoint = ActiveTabMsg SelectEndpoint
    , onNewApp = NewApp >> ActiveTabMsg
    , endpoints = endpoints
    }


homeConfig : Home.Config Msg
homeConfig =
    { onNewTabIn = NewTabIn
    , onGoAddress = GoAddress >> ActiveTabMsg
    }


webserverConfig : Browser.Config msg -> Webserver.Config Msg
webserverConfig { endpoints } =
    { toMsg = WebserverMsg >> ActiveTabMsg
    , onLogin = \a b -> ActiveTabMsg <| Login a b
    , onLogout = ActiveTabMsg Logout
    , onCrack = Crack >> ActiveTabMsg
    , onAnyMap = AnyMap >> ActiveTabMsg
    , onPublicDownload = PublicDownload
    , onSelectEndpoint = ActiveTabMsg SelectEndpoint
    , onNewApp = NewApp >> ActiveTabMsg
    , endpoints = endpoints
    }
