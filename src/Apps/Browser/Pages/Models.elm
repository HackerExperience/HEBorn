module Apps.Browser.Pages.Models
    exposing
        ( Model(..)
        , initialModel
        , getTitle
        , isLoading
        )

import Game.Web.Types as Web
import Apps.Browser.Pages.NotFound.Models as PageNotFound
import Apps.Browser.Pages.Webserver.Models as PageWebserver
import Apps.Browser.Pages.NoWebserver.Models as PageNoWebserver
import Apps.Browser.Pages.DownloadCenter.Models as DownloadCenter
import Apps.Browser.Pages.Bank.Models as PageBank


type Model
    = NotFoundModel PageNotFound.Model
    | HomeModel
    | WebserverModel PageWebserver.Model
    | NoWebserverModel PageNoWebserver.Model
    | ProfileModel
    | WhoisModel
    | DownloadCenterModel DownloadCenter.Model
    | ISPModel
    | BankModel PageBank.Model
    | StoreModel
    | BTCModel
    | FBIModel
    | NewsModel
    | BithubModel
    | MissionCenterModel
      -- Virtual ones
    | LoadingModel String
    | BlankModel


initialModel : Web.Site -> Model
initialModel ({ url, type_, meta } as site) =
    case type_ of
        Web.NotFound ->
            NotFoundModel <| PageNotFound.initialModel url

        Web.Home ->
            HomeModel

        Web.Webserver content ->
            WebserverModel <| PageWebserver.initialModel url meta content

        Web.NoWebserver ->
            NoWebserverModel <| PageNoWebserver.initialModel meta

        Web.Profile ->
            ProfileModel

        Web.Whois ->
            WhoisModel

        Web.DownloadCenter content ->
            DownloadCenterModel <| DownloadCenter.initialModel meta content

        Web.ISP ->
            ISPModel

        Web.Bank content ->
            BankModel <| PageBank.initialModel url content

        Web.Store ->
            StoreModel

        Web.BTC ->
            BTCModel

        Web.FBI ->
            FBIModel

        Web.News ->
            NewsModel

        Web.Bithub ->
            BithubModel

        Web.MissionCenter ->
            MissionCenterModel


getTitle : Model -> String
getTitle model =
    case model of
        NotFoundModel model ->
            PageNotFound.getTitle model

        HomeModel ->
            "Home"

        WebserverModel model ->
            PageWebserver.getTitle model

        NoWebserverModel model ->
            PageNoWebserver.getTitle model

        ProfileModel ->
            "Your Profile"

        WhoisModel ->
            "Whois"

        DownloadCenterModel _ ->
            "Download Center"

        ISPModel ->
            "Internet Provider"

        BankModel model ->
            PageBank.getTitle model

        StoreModel ->
            "Store"

        BTCModel ->
            "BTV"

        FBIModel ->
            "Federal Bureal Intelligence"

        NewsModel ->
            "News"

        BithubModel ->
            "Software Reasearch"

        MissionCenterModel ->
            "Head Quarters"

        LoadingModel _ ->
            "Loading..."

        BlankModel ->
            "New Tab"


isLoading : Model -> Bool
isLoading model =
    case model of
        LoadingModel _ ->
            True

        _ ->
            False
