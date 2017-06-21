module Apps.Browser.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Html.CssHelpers
import Css exposing (pct, width, asPairs)
import Game.Models as Game
import Apps.Browser.Messages exposing (Msg(..))
import Apps.Browser.Models exposing (Model, Browser)
import Apps.Browser.Menu.View exposing (menuView, menuNav, menuContent)
import Apps.Browser.Pages exposing (PageContent(..))
import Apps.Browser.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "browser"


styles : List Css.Mixin -> Attribute Msg
styles =
    Css.asPairs >> style


view : Game.Model -> Model -> Html Msg
view game ({ app } as model) =
    div
        [ menuContent
        , class [ Window, Content, Client ]
        ]
        [ viewToolbar app
        , viewPg app.page.content
        , menuView model
        ]


viewToolbar : Browser -> Html Msg
viewToolbar browser =
    div [ class [ Toolbar ] ]
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
                [ onSubmit AddressEnter ]
                [ input
                    [ value browser.addressBar
                    , onInput UpdateAddress
                    ]
                    []
                ]
            ]
        ]


viewPg : PageContent -> Html Msg
viewPg pg =
    div [ class [ PageContent ] ] (contentPg pg)



-- PAGES


contentPg : PageContent -> List (Html Msg)
contentPg pg =
    case pg of
        PgBlank ->
            []

        PgWelcome addr ->
            pgWelcomeHost addr

        PgCustom realContent ->
            realContent

        PgError404 ->
            [ text "404" ]


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
