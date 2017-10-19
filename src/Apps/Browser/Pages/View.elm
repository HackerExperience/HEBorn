module Apps.Browser.Pages.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as Game
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.CommonActions exposing (CommonActions)
import Apps.Browser.Pages.NotFound.View as NotFound
import Apps.Browser.Pages.Home.View as Home
import Apps.Browser.Pages.Webserver.Messages as Webserver
import Apps.Browser.Pages.Webserver.View as Webserver
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
            NotFound.view
                |> ignoreMsg

        HomeModel ->
            Home.view
                |> globalMsg

        WebserverModel model ->
            Webserver.view data model
                |> Html.map handleWebserver

        ProfileModel ->
            Profile.view
                |> ignoreMsg

        WhoisModel ->
            Whois.view
                |> ignoreMsg

        DownloadCenterModel model ->
            DownloadCenter.view data model
                |> Html.map handleDownloadCenter

        ISPModel ->
            ISP.view
                |> ignoreMsg

        BankModel model ->
            Bank.view model
                |> ignoreMsg

        StoreModel ->
            Store.view
                |> ignoreMsg

        BTCModel ->
            BTC.view
                |> ignoreMsg

        FBIModel ->
            FBI.view
                |> ignoreMsg

        NewsModel ->
            News.view
                |> ignoreMsg

        BithubModel ->
            Bithub.view
                |> ignoreMsg

        MissionCenterModel ->
            MissionCenter.view
                |> ignoreMsg

        LoadingModel _ ->
            div [] []

        BlankModel ->
            div [] []


handleWebserver : Webserver.Msg -> Msg
handleWebserver msg =
    case msg of
        Webserver.GlobalMsg msg ->
            GlobalMsg msg

        _ ->
            WebserverMsg msg


handleDownloadCenter : DownloadCenter.Msg -> Msg
handleDownloadCenter msg =
    case msg of
        DownloadCenter.GlobalMsg msg ->
            GlobalMsg msg

        _ ->
            DownloadCenterMsg msg


ignoreMsg : Html a -> Html Msg
ignoreMsg =
    Html.map (always Ignore)


globalMsg : Html CommonActions -> Html Msg
globalMsg =
    Html.map GlobalMsg
