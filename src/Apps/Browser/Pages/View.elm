module Apps.Browser.Pages.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as Game
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.CommonActions exposing (CommonActions)
import Apps.Browser.Pages.NotFound.View as NotFound
import Apps.Browser.Pages.Home.View as Home
import Apps.Browser.Pages.Webserver.View as Webserver
import Apps.Browser.Pages.NoWebserver.Messages as NoWebserver
import Apps.Browser.Pages.NoWebserver.View as NoWebserver
import Apps.Browser.Pages.Profile.View as Profile
import Apps.Browser.Pages.Whois.View as Whois
import Apps.Browser.Pages.DownloadCenter.Messages as DownloadCenter
import Apps.Browser.Pages.DownloadCenter.View as DownloadCenter
import Apps.Browser.Pages.ISP.View as ISP
import Apps.Browser.Pages.Bank.View as Bank
import Apps.Browser.Pages.Store.View as Store
import Apps.Browser.Pages.BTC.View as BTC
import Apps.Browser.Pages.FBI.View as FBI
import Apps.Browser.Pages.News.View as News
import Apps.Browser.Pages.Bithub.View as Bithub
import Apps.Browser.Pages.MissionCenter.View as MissionCenter


view : Game.Data -> Model -> Html Msg
view data model =
    case model of
        NotFoundModel _ ->
            ignoreMsg <| NotFound.view

        HomeModel ->
            Html.map GlobalMsg Home.view

        WebserverModel model ->
            ignoreMsg <| Webserver.view model

        NoWebserverModel model ->
            Html.map NoWebserverMsg <| NoWebserver.view data model

        ProfileModel ->
            ignoreMsg <| Profile.view

        WhoisModel ->
            ignoreMsg <| Whois.view

        DownloadCenterModel model ->
            Html.map DownloadCenterMsg <| DownloadCenter.view data model

        ISPModel ->
            ignoreMsg <| ISP.view

        BankModel model ->
            ignoreMsg <| Bank.view model

        StoreModel ->
            ignoreMsg <| Store.view

        BTCModel ->
            ignoreMsg <| BTC.view

        FBIModel ->
            ignoreMsg <| FBI.view

        NewsModel ->
            ignoreMsg <| News.view

        BithubModel ->
            ignoreMsg <| Bithub.view

        MissionCenterModel ->
            ignoreMsg <| MissionCenter.view

        LoadingModel _ ->
            div [] []

        BlankModel ->
            div [] []


ignoreMsg : Html a -> Html Msg
ignoreMsg =
    Html.map (always Ignore)



--globalMsg : Html CommonActions -> Html Msg
--globalMsg =
--
--handleNoWebserver : NoWebserver.Msg -> Msg
--handleNoWebserver msg =
--    case msg of
--        NoWebserver.GlobalMsg msg ->
--            GlobalMsg msg
--        _ ->
--            NoWebserverMsg msg
--handleDownloadCenter : DownloadCenter.Msg -> Msg
--handleDownloadCenter msg =
--    case msg of
--        DownloadCenter.GlobalMsg msg ->
--            GlobalMsg msg
--        _ ->
--            DownloadCenterMsg msg
