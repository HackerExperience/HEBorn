module Apps.Browser.Widgets.HackingToolkit.View
    exposing
        ( Config
        , hackingToolkit
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Network.Types exposing (NIP)
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))
import Apps.Browser.Widgets.HackingToolkit.Model exposing (..)


type alias Config msg =
    { onInput : String -> msg
    , onCommonAction : CommonActions -> msg
    }


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkit : Config msg -> Model -> Html msg
hackingToolkit config state =
    div []
        [ loginForm config state
        , div [ class [ LoginPageFooter ] ]
            [ crackBtn config state
            , anyMapBtn config state
            ]
        ]


loginForm : Config msg -> Model -> Html msg
loginForm config state =
    let
        inputText =
            Maybe.withDefault "" state.password
    in
        div [ class [ LoginPageForm ] ]
            [ div []
                [ input
                    [ placeholder "Password"
                    , value inputText
                    , onInput config.onInput
                    ]
                    []
                , div
                    [ onClick <|
                        config.onCommonAction <|
                            Login state.target inputText
                    ]
                    [ text "E" ]
                ]
            ]


crackBtn : Config msg -> Model -> Html msg
crackBtn config state =
    div
        [ onClick <| config.onCommonAction <| Crack state.target
        ]
        [ text "C"
        , br [] []
        , text "Crack"
        ]


anyMapBtn : Config msg -> Model -> Html msg
anyMapBtn config state =
    div
        [ onClick <| config.onCommonAction <| AnyMap state.target
        ]
        [ text "M"
        , br [] []
        , text "AnyMap"
        ]
