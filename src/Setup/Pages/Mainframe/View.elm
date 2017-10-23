module Setup.Pages.Mainframe.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Html.Attributes exposing (placeholder, disabled)
import Html.CssHelpers
import Game.Models as Game
import Setup.Resources exposing (..)
import Setup.Pages.Helpers exposing (withHeader)
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Game.Model -> Model -> Html msg
view { toMsg, onNext, onPrevious } game model =
    withHeader [ class [ StepWelcome ] ]
        [ div [] [ h2 [] [ text "Initial server name:" ] ]
        , hostnameInput toMsg model
        , div []
            [ button [ onClick onPrevious ] [ text "BACK" ]
            , nextBtn onNext model
            ]
        ]


hostnameInput : (Msg -> msg) -> Model -> Html msg
hostnameInput toMsg model =
    input
        [ onInput <| Mainframe >> toMsg
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
