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
import Apps.Browser.Pages.Bank.Models as PageBank


type Model
    = NotFoundModel PageNotFound.Model
    | HomeModel
    | WebserverModel PageWebserver.Model
    | NoWebserverModel PageNoWebserver.Model
    | ProfileModel
    | WhoisModel
    | DownloadCenterModel
    | ISPModel
    | BankModel PageBank.Model
    | StoreModel
    | BTCModel
    | FBIModel
    | NewsModel
    | BithubModel
    | MissionCenterModel
      -- Virtual ones
    | LoadingModel
    | BlankModel


initialModel : Web.Site -> Model
initialModel ({ url, type_ } as site) =
    case type_ of
        Web.NotFound ->
            NotFoundModel <| PageNotFound.initialModel url

        Web.Home ->
            HomeModel

        Web.Webserver meta ->
            WebserverModel <| PageWebserver.initialModel site meta

        Web.NoWebserver ->
            NoWebserverModel <| PageNoWebserver.initialModel site

        Web.Profile ->
            ProfileModel

        Web.Whois ->
            WhoisModel

        Web.DownloadCenter meta ->
            DownloadCenterModel

        Web.ISP ->
            ISPModel

        Web.Bank meta ->
            BankModel <| PageBank.initialModel url meta

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

        DownloadCenterModel ->
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

        LoadingModel ->
            "Loading..."

        BlankModel ->
            "New Tab"


isLoading : Model -> Bool
isLoading model =
    case model of
        LoadingModel ->
            True

        _ ->
            False
