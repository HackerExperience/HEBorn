module Setup.Pages.CustomWelcome.View exposing (Config, view)

import Html exposing (..)
import Html.Events exposing (onClick)
import Html.CssHelpers
import Setup.Resources exposing (..)
import Setup.Pages.Helpers exposing (withHeader)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


type alias Config msg =
    { onNext : msg }


view : Config msg -> Html msg
view { onNext } =
    withHeader [ class [ StepWelcome ] ] <|
        div []
            [ h2 [] [ text "Hello again!" ]
            , p []
                [ text "We've some new features for you, but you need to setup some things first." ]
            , div []
                [ button [ onClick onNext ] [ text "LET'S GO" ] ]
            ]
