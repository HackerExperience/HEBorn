module Apps.Browser.Pages.Default.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Apps.Browser.Resources exposing (Classes(..), prefix)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Html Never
view =
    div []
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
