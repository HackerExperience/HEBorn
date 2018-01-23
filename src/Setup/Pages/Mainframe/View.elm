module Setup.Pages.Mainframe.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Html.Attributes exposing (placeholder, disabled)
import Html.CssHelpers
import Setup.Resources exposing (..)
import Setup.Settings as Settings exposing (Settings)
import Setup.Pages.Helpers exposing (withHeader)
import Setup.Pages.Mainframe.Models exposing (..)
import Setup.Pages.Mainframe.Messages exposing (..)
import Setup.Pages.Mainframe.Config exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view ({ toMsg, onPrevious } as config) model =
    withHeader [ class [ StepWelcome ] ]
        [ div [] [ h2 [] [ text "Initial server name:" ] ]
        , hostnameInput toMsg model
        , div []
            [ button [ onClick onPrevious ] [ text "BACK" ]
            , nextBtn config model
            ]
        ]


hostnameInput : (Msg -> msg) -> Model -> Html msg
hostnameInput toMsg model =
    input
        [ onInput <| Mainframe >> toMsg
        , placeholder "Hostname"
        ]
        [ text <| Maybe.withDefault "" model.hostname ]


nextBtn : Config msg -> Model -> Html msg
nextBtn { toMsg, onNext } model =
    button
        [ onClick <|
            if isOkay model then
                onNext <| settings model
            else
                toMsg <| Validate
        ]
        [ text "NEXT" ]
