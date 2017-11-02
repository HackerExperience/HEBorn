module Setup.Pages.Welcome.View exposing (Config, view)

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
    withHeader [ class [ StepWelcome ] ]
        [ h2 [] [ text "Hello!" ]
        , p []
            [ text "I'm looking for someone to share in an adventure..." ]
        , p []
            [ text "Do you believe in computer fairies? Their job is to protect all your private information. But, be ware, they don't exist!" ]
        , p []
            [ text "So who is protecting you? No one! In the land of bits and pixels there are no gods!" ]
        , p []
            [ text "What are you still doing in this screen? You better be going now, if you really wanna play..." ]
        , div []
            [ button [ onClick onNext ] [ text "I'M IN" ] ]
        ]
