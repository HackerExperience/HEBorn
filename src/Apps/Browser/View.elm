module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Data as Game
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import UI.Widgets.Modal exposing (modalPickStorage)
import Apps.Browser.Pages.NotFound.View as NotFound
import Apps.Browser.Pages.Home.View as Home
import Apps.Browser.Pages.Webserver.View as Webserver
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
import Apps.Browser.Menu.View exposing (menuView, menuNav, menuTab)
import Apps.Browser.Pages.Configs exposing (..)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Models exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


styles : List Css.Style -> Attribute Msg
styles =
    Css.asPairs >> style


view : Config msg -> Model -> Html msg
view config model =
    let
        tab =
            getNowTab model
    in
        Html.map config.toMsg <|
            div
                [ class [ Window, Content, Client ]
                ]
                [ viewTabs model
                , viewToolbar tab
                , viewPg config tab
                , menuView model
                ]


renderToolbarBtn : Bool -> String -> msg -> Html msg
renderToolbarBtn active label callback =
    div
        [ class
            (if active then
                [ Btn ]
             else
                [ Btn, InactiveBtn ]
            )
        , onClick callback
        ]
        [ text label ]


viewToolbar : Tab -> Html Msg
viewToolbar browser =
    let
        btnClass lengthFn =
            if (lengthFn browser) > 0 then
                [ Btn ]
            else
                [ Btn, InactiveBtn ]

        genBtn lengthFn action label =
            div
                [ class <| btnClass lengthFn
                , onClick action
                ]
                [ text label ]

        prevBtn =
            genBtn
                ((.previousPages) >> List.length)
                (ActiveTabMsg <| GoPrevious)
                "<"

        nextBtn =
            genBtn
                ((.nextPages) >> List.length)
                (ActiveTabMsg <| GoNext)
                ">"

        goBtn =
            genBtn
                ((.addressBar) >> String.length)
                (ActiveTabMsg <| GoAddress browser.addressBar)
                "%"
    in
        div
            [ menuNav
            , class [ Toolbar ]
            ]
            [ prevBtn
            , nextBtn
            , goBtn
            , div
                [ class [ AddressBar ] ]
                [ Html.form
                    [ browser.addressBar
                        |> GoAddress
                        |> ActiveTabMsg
                        |> onSubmit
                    ]
                    [ input
                        [ value browser.addressBar
                        , onInput (ActiveTabMsg << UpdateAddress)
                        ]
                        []
                    ]
                ]
            ]


viewTabLabel : Tabs -> Bool -> Int -> ( List (Attribute Msg), List (Html Msg) )
viewTabLabel src _ tab =
    getTab tab src
        |> getPage
        |> getTitle
        |> text
        |> List.singleton
        |> (,) [ menuTab tab ]


viewTabs : Model -> Html Msg
viewTabs b =
    hzTabs
        ((==) b.nowTab)
        (viewTabLabel b.tabs)
        ChangeTab
        (b.leftTabs ++ (b.nowTab :: b.rightTabs))


viewPg : Config msg -> Tab -> Html Msg
viewPg config { page, modal } =
    div
        [ class [ PageContent ] ]
        [ viewPage config page
        , case modal of
            Just (ForDownload source file) ->
                let
                    storages =
                        config.activeServer
                            |> .storages

                    onPick chosen =
                        chosen
                            |> Maybe.map (ReqDownload source file)
                            |> Maybe.withDefault
                                (ActiveTabMsg <| EnterModal Nothing)
                in
                    modalPickStorage storages onPick

            Nothing ->
                text ""
        ]


viewPage : Config msg -> Page -> Html Msg
viewPage config page =
    case page of
        NotFoundModel _ ->
            NotFound.view

        HomeModel ->
            Home.view homeConfig

        WebserverModel page ->
            Webserver.view (webserverConfig config) page

        ProfileModel ->
            Profile.view

        WhoisModel ->
            Whois.view

        DownloadCenterModel page ->
            DownloadCenter.view (downloadCenterConfig config) page

        ISPModel ->
            ISP.view

        BankModel page ->
            Bank.view bankConfig page

        StoreModel ->
            Store.view

        BTCModel ->
            BTC.view

        FBIModel ->
            FBI.view

        NewsModel ->
            News.view

        BithubModel ->
            Bithub.view

        MissionCenterModel ->
            MissionCenter.view

        LoadingModel _ ->
            div [] []

        BlankModel ->
            div [] []
