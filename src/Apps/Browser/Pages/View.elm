module Apps.Browser.Pages.View exposing (view)

import Html exposing (Html, div, text)
import Game.Data as GameData
import Apps.Browser.Pages.Models exposing (..)
import Apps.Browser.Pages.Messages exposing (..)
import Apps.Browser.Pages.Blank.View as Blank
import Apps.Browser.Pages.NotFound.View as NotFound
import Apps.Browser.Pages.Home.Messages as Home
import Apps.Browser.Pages.Home.View as Home
import Apps.Browser.Pages.Profile.View as Profile
import Apps.Browser.Pages.Directory.View as Directory
import Apps.Browser.Pages.MissionCenter.View as MissionCenter
import Apps.Browser.Pages.DownloadCenter.View as DownloadCenter
import Apps.Browser.Pages.ISP.View as ISP
import Apps.Browser.Pages.FBI.View as FBI
import Apps.Browser.Pages.News.View as News


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

        BlankModel ->
            Html.map (always BlankMsg) Blank.view

        ProfileModel ->
            Html.map (always ProfileMsg) Profile.view

        DirectoryModel ->
            Html.map (always DirectoryMsg) Directory.view

        MissionCenterModel ->
            Html.map (always MissionCenterMsg) MissionCenter.view

        DownloadCenterModel ->
            Html.map (always DownloadCenterMsg) DownloadCenter.view

        ISPModel ->
            Html.map (always ISPMsg) ISP.view

        FBIModel ->
            Html.map (always FBIMsg) FBI.view

        NewsModel ->
            Html.map (always NewsMsg) News.view

        _ ->
            Html.map (always UnknownMsg) Blank.view
