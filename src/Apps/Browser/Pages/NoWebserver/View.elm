module Apps.Browser.Pages.NoWebserver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.CssHelpers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.NoWebserver.Models exposing (Model)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Model -> Html Never
view model =
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
