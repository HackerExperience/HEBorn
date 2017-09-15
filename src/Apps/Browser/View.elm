module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Data as GameData
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Models exposing (..)
import Apps.Browser.Menu.View exposing (menuView, menuNav, menuTab)
import Apps.Browser.Pages.Messages as Pages
import Apps.Browser.Pages.Models as Pages
import Apps.Browser.Pages.View as Pages
import Apps.Browser.Resources exposing (Classes(..), prefix)
import UI.Widgets.HorizontalTabs exposing (hzTabs)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


styles : List Css.Style -> Attribute Msg
styles =
    Css.asPairs >> style


view : GameData.Data -> Model -> Html Msg
view data model =
    let
        app =
            getNowTab model
    in
        div
            [ class [ Window, Content, Client ]
            ]
            [ viewTabs model
            , viewToolbar app
            , viewPg data app.page
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
                GoPrevious
                "<"

        nextBtn =
            genBtn
                ((.nextPages) >> List.length)
                GoNext
                ">"

        goBtn =
            genBtn
                ((.addressBar) >> String.length)
                (GoAddress browser.addressBar)
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
                    [ onSubmit <| GoAddress browser.addressBar ]
                    [ input
                        [ value browser.addressBar
                        , onInput UpdateAddress
                        ]
                        []
                    ]
                ]
            ]


viewTabLabel : Tabs -> Bool -> Int -> ( List (Attribute Msg), List (Html Msg) )
viewTabLabel src _ tab =
    getTab tab src
        |> getPage
        |> Pages.getTitle
        |> text
        |> List.singleton
        |> (,) [ menuTab tab ]


viewTabs : Model -> Html Msg
viewTabs b =
    hzTabs
        ((==) b.nowTab)
        (viewTabLabel b.tabs)
        TabGo
        (b.leftTabs ++ (b.nowTab :: b.rightTabs))


pageMsgIntersept : Pages.Msg -> Msg
pageMsgIntersept msg =
    case msg of
        Pages.BrowserGoAddress url ->
            GoAddress url

        Pages.BrowserTabAddress url ->
            NewTabInAddress url

        _ ->
            PageMsg


viewPg : GameData.Data -> Pages.Model -> Html Msg
viewPg data pg =
    div
        [ class [ PageContent ] ]
        [ (Html.map pageMsgIntersept (Pages.view data pg)) ]
