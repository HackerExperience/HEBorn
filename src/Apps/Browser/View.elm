module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Data as Game
import Apps.Browser.Messages exposing (..)
import Apps.Browser.Models exposing (..)
import Apps.Browser.Menu.View exposing (menuView, menuNav, menuTab)
import Apps.Browser.Pages.Messages as Pages
import Apps.Browser.Pages.CommonActions as Common
import Apps.Browser.Pages.Models as Pages
import Apps.Browser.Pages.View as Pages
import Apps.Browser.Resources exposing (Classes(..), prefix)
import UI.Widgets.HorizontalTabs exposing (hzTabs)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


styles : List Css.Style -> Attribute Msg
styles =
    Css.asPairs >> style


view : Game.Data -> Model -> Html Msg
view data model =
    let
        tab =
            getNowTab model
    in
        div
            [ class [ Window, Content, Client ]
            ]
            [ viewTabs model
            , viewToolbar tab
            , viewPg data tab.page
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
        |> Pages.getTitle
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


pageMsgIntersept : Pages.Msg -> Msg
pageMsgIntersept msg =
    case msg of
        Pages.GlobalMsg msg ->
            case msg of
                Common.GoAddress url ->
                    ActiveTabMsg <| GoAddress url

                Common.NewTabIn url ->
                    NewTabIn url

                Common.Crack ip ->
                    Crack ip

        _ ->
            ActiveTabMsg <| PageMsg msg


viewPg : Game.Data -> Pages.Model -> Html Msg
viewPg data pg =
    div
        [ class [ PageContent ] ]
        [ (Html.map pageMsgIntersept (Pages.view data pg)) ]
