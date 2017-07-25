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
            getApp model
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


viewToolbar : Browser -> Html Msg
viewToolbar browser =
    div
        [ menuNav
        , class [ Toolbar ]
        ]
        [ div
            -- TODO: Add classes
            [ class
                (if (List.length browser.previousPages) > 0 then
                    [ Btn ]
                 else
                    [ Btn, InactiveBtn ]
                )
            , onClick GoPrevious
            ]
            [ text "<" ]
        , div
            [ class
                (if (List.length browser.nextPages) > 0 then
                    [ Btn ]
                 else
                    [ Btn, InactiveBtn ]
                )
            , onClick GoNext
            ]
            [ text ">" ]
        , div
            [ class
                (if (String.length browser.addressBar) > 0 then
                    [ Btn ]
                 else
                    [ Btn, InactiveBtn ]
                )
            ]
            [ text "%" ]
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



-- PAGES


pgWelcomeHost : String -> List (Html Msg)
pgWelcomeHost ip =
    [ div [ class [ LoginPageHeader ] ] [ text "No web server running" ]
    , div [ class [ LoginPageForm ] ]
        [ div []
            [ input [ placeholder "Password" ] []
            , text "E"
            ]
        ]
    , div [ class [ LoginPageFooter ] ]
        [ div []
            [ text "C"
            , br [] []
            , text "Crack"
            ]
        , div []
            [ text "M"
            , br [] []
            , text "AnyMap"
            ]
        ]
    ]
