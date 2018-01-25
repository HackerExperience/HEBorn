module Setup.Pages.Mainframe.View exposing (view)

import Html exposing (..)
import Html.Events exposing (onClick, onInput, onSubmit)
import Html.Attributes exposing (placeholder, disabled, action)
import Html.CssHelpers
import Setup.Resources exposing (..)
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
        , hostnameInput config model
        , div []
            [ button [ onClick onPrevious ] [ text "BACK" ]
            , nextBtn config model
            ]
        ]


hostnameInput : Config msg -> Model -> Html msg
hostnameInput { toMsg } model =
    form
        [ action "javascript:void(0);"
        , onSubmit (toMsg <| Validate)
        ]
        [ input
            [ onInput <| Mainframe >> toMsg
            , placeholder "Hostname"
            ]
            [ text <| Maybe.withDefault "" model.hostname ]
        ]


nextBtn : Config msg -> Model -> Html msg
nextBtn { toMsg } model =
    button
        [ onClick (toMsg <| Validate) ]
        [ text "NEXT" ]
