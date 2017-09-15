module Apps.Browser.Pages.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as GameData
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.NotFound.View as NotFound
import Apps.Browser.Pages.Home.Messages as Home
import Apps.Browser.Pages.Home.View as Home
import Apps.Browser.Pages.Webserver.View as Webserver
import Apps.Browser.Pages.NoWebserver.View as NoWebserver
import Apps.Browser.Pages.Profile.View as Profile
import Apps.Browser.Pages.Whois.View as Whois
import Apps.Browser.Pages.DownloadCenter.View as DownloadCenter
import Apps.Browser.Pages.ISP.View as ISP
import Apps.Browser.Pages.Bank.View as Bank
import Apps.Browser.Pages.Store.View as Store
import Apps.Browser.Pages.BTC.View as BTC
import Apps.Browser.Pages.FBI.View as FBI
import Apps.Browser.Pages.News.View as News
import Apps.Browser.Pages.Bithub.View as Bithub
import Apps.Browser.Pages.MissionCenter.View as MissionCenter


view : GameData.Data -> Model -> Html Msg
view data model =
    case model of
        NotFoundModel _ ->
            Html.map (always NotFoundMsg) NotFound.view

        HomeModel ->
            Html.map
                (\msg ->
                    case msg of
                        Home.BrowserGoAddress url ->
                            BrowserGoAddress url

                        Home.BrowserTabAddress url ->
                            BrowserTabAddress url
                )
                Home.view

        WebserverModel model ->
            Html.map (always WebserverMsg) (Webserver.view model)

        NoWebserverModel model ->
            Html.map (always NoWebserverMsg) (NoWebserver.view model)

        ProfileModel ->
            Html.map (always ProfileMsg) Profile.view

        WhoisModel ->
            Html.map (always WhoisMsg) Whois.view

        DownloadCenterModel ->
            Html.map (always DownloadCenterMsg) DownloadCenter.view

        ISPModel ->
            Html.map (always ISPMsg) ISP.view

        BankModel model ->
            Html.map (always BankMsg) (Bank.view model)

        StoreModel ->
            Html.map (always StoreMsg) Store.view

        BTCModel ->
            Html.map (always BTCMsg) BTC.view

        FBIModel ->
            Html.map (always FBIMsg) FBI.view

        NewsModel ->
            Html.map (always NewsMsg) News.view

        BithubModel ->
            Html.map (always BithubMsg) Bithub.view

        MissionCenterModel ->
            Html.map (always MissionCenterMsg) MissionCenter.view

        LoadingModel ->
            div [] []

        BlankModel ->
            div [] []
