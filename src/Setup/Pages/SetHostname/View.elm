module Setup.Pages.SetHostname.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Html.Attributes exposing (placeholder, disabled)
import Html.CssHelpers
import Game.Models as Game
import Setup.Resources exposing (..)
import Setup.Pages.Helpers exposing (withHeader)
import Setup.Pages.SetHostname.Models exposing (..)
import Setup.Pages.SetHostname.Messages exposing (..)
import Setup.Pages.SetHostname.Config exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Game.Model -> Model -> Html msg
view { toMsg, onNext } game model =
    withHeader [ class [ StepWelcome ] ] <|
        div []
            [ div [] [ h2 [] [ text "Initial server name:" ] ]
            , hostnameInput toMsg model
            , div [] [ nextBtn onNext model ]
            ]


hostnameInput : (Msg -> msg) -> Model -> Html msg
hostnameInput toMsg model =
    input
        [ onInput <| SetHostname >> toMsg
        , onBlur <| toMsg Validate
        , placeholder "hostname"
        ]
        [ text <| Maybe.withDefault "" model.hostname ]


nextBtn : msg -> Model -> Html msg
nextBtn onNext model =
    let
        attrs =
            if isOkay model then
                [ onClick onNext ]
            else
                [ disabled True ]
    in
        button attrs [ text "NEXT" ]
