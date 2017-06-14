module Apps.Browser.Pages exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Apps.Browser.Messages exposing (Msg)
import Apps.Browser.Style exposing (Classes(..))


{ id, class, classList } =
    Html.CssHelpers.withNamespace "browser"


type alias PageURL =
    String


type alias PageTitle =
    String


type alias PageContent =
    List (Html Msg)


getPageInitialContent : PageURL -> List (Html Msg)
getPageInitialContent url =
    case url of
        "about:blank" ->
            []

        "localhost" ->
            pgWelcomeHost "localhost"

        _ ->
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
