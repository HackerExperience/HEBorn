module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import ContextMenu
import Css exposing (pct, width, asPairs)
import Apps.Browser.Config exposing (..)
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Resources exposing (Classes(..), prefix)
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
import UI.Widgets.HorizontalTabs exposing (hzTabs)
import UI.Widgets.Modal exposing (modalPickStorage, modalOk)


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
        div
            [ class [ Window, Content, Client ]
            ]
            [ viewTabs config model
            , viewToolbar config tab
            , viewPg config tab
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


viewToolbar : Config msg -> Tab -> Html msg
viewToolbar { menuAttr, toMsg } browser =
    let
        btnClass lengthFn =
            if (lengthFn browser) > 0 then
                [ Btn ]
            else
                [ Btn, InactiveBtn ]

        genBtn lengthFn action label =
            div
                [ class <| btnClass lengthFn
                , onClick <| toMsg action
                ]
                [ text label ]

        prevBtn =
            genBtn
                ((.previousPages) >> List.length)
                (ActiveTabMsg GoPrevious)
                "<"

        nextBtn =
            genBtn
                ((.nextPages) >> List.length)
                (ActiveTabMsg GoNext)
                ">"

        goBtn =
            genBtn
                ((.addressBar) >> String.length)
                (ActiveTabMsg <| GoAddress browser.addressBar)
                "%"

        menuNav =
            menuAttr
                [ [ ( ContextMenu.item "Previous", toMsg <| ActiveTabMsg GoPrevious )
                  , ( ContextMenu.item "Next", toMsg <| ActiveTabMsg GoNext )
                  , browser.addressBar
                        |> GoAddress
                        |> ActiveTabMsg
                        |> toMsg
                        |> (,) (ContextMenu.item "Go")
                  , "about:home"
                        |> GoAddress
                        |> ActiveTabMsg
                        |> toMsg
                        |> (,) (ContextMenu.item "Home")
                  ]
                ]
    in
        div
            [ class [ Toolbar ]
            , menuNav
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
                        |> toMsg
                        |> onSubmit
                    ]
                    [ input
                        [ value browser.addressBar
                        , UpdateAddress
                            >> ActiveTabMsg
                            >> toMsg
                            |> onInput
                        ]
                        []
                    ]
                ]
            ]


viewTabLabel : Config msg -> Tabs -> Bool -> Int -> ( List (Attribute msg), List (Html msg) )
viewTabLabel config src _ tab =
    getTab tab src
        |> getPage
        |> getTitle
        |> text
        |> List.singleton
        |> (,) [ menuTab config tab ]


menuTab : Config msg -> Int -> Attribute msg
menuTab { menuAttr, toMsg } tab =
    [ [ ( ContextMenu.item "New Tab", toMsg NewTab )
      , ( ContextMenu.item "Close", toMsg <| DeleteTab tab )
      ]
    ]
        |> menuAttr


viewTabs : Config msg -> Model -> Html msg
viewTabs config b =
    hzTabs
        ((==) b.nowTab)
        (viewTabLabel config b.tabs)
        (config.toMsg << ChangeTab)
        (b.leftTabs ++ (b.nowTab :: b.rightTabs))


viewPg : Config msg -> Tab -> Html msg
viewPg config { page, modal } =
    div
        [ class [ PageContent ] ]
        [ viewPage config page
        , Html.map config.toMsg <|
            case modal of
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

                Just ImpossibleToLogin ->
                    modalOk (Just "Impossible to login!")
                        "Maybe password was invalid or try again later."
                        (ActiveTabMsg <| EnterModal Nothing)

                Nothing ->
                    text ""
        ]


viewPage : Config msg -> Page -> Html msg
viewPage config page =
    case page of
        NotFoundModel _ ->
            NotFound.view

        HomeModel ->
            Home.view (homeConfig config)

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
            Bank.view (bankConfig config) page

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
