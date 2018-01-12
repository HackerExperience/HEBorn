module Apps.Browser.Pages.Configs exposing (..)

import Apps.Browser.Pages.Bank.Config as Bank
import Apps.Browser.Pages.DownloadCenter.Config as DownloadCenter
import Apps.Browser.Pages.Home.Config as Home
import Apps.Browser.Pages.Webserver.Config as Webserver
import Apps.Browser.Pages.Store.Config as Store
import Apps.Browser.Messages exposing (..)


bankConfig : Bank.Config Msg
bankConfig =
    { toMsg = BankMsg >> ActiveTabMsg }


downloadCenterConfig : DownloadCenter.Config Msg
downloadCenterConfig =
    { toMsg = DownloadCenterMsg >> ActiveTabMsg
    , onLogin = \a b -> ActiveTabMsg <| Login a b
    , onLogout = ActiveTabMsg Logout
    , onCrack = Crack >> ActiveTabMsg
    , onAnyMap = AnyMap >> ActiveTabMsg
    , onPublicDownload = PublicDownload
    , onSelectEndpoint = ActiveTabMsg SelectEndpoint
    , onOpenApp = OpenApp >> ActiveTabMsg
    }


homeConfig : Home.Config Msg
homeConfig =
    { onNewTabIn = NewTabIn
    , onGoAddress = GoAddress >> ActiveTabMsg
    }


webserverConfig : Webserver.Config Msg
webserverConfig =
    { toMsg = WebserverMsg >> ActiveTabMsg
    , onLogin = \a b -> ActiveTabMsg <| Login a b
    , onLogout = ActiveTabMsg Logout
    , onCrack = Crack >> ActiveTabMsg
    , onAnyMap = AnyMap >> ActiveTabMsg
    , onPublicDownload = PublicDownload
    , onSelectEndpoint = ActiveTabMsg SelectEndpoint
    , onOpenApp = OpenApp >> ActiveTabMsg
    }


storeConfig : Store.Config Msg
storeConfig =
    { toMsg = StoreMsg >> ActiveTabMsg
    , onPurchase = StoreMsg >> ActiveTabMsg
    }
