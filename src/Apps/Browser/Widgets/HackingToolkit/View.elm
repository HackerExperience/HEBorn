module Apps.Browser.Widgets.HackingToolkit.View
    exposing
        ( Config
        , hackingToolkit
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))
import Apps.Browser.Widgets.HackingToolkit.Model exposing (..)


type alias Config msg =
    { onInput : String -> msg
    , onCommonAction : CommonActions -> msg
    , onEnterPanel : msg
    , showPassword : Bool
    }


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkit : Config msg -> Model -> Html msg
hackingToolkit config model =
    div []
        [ goPanelView config model
        , div [ class [ LoginPageFooter ] ]
            [ crackBtn config model
            , anyMapBtn config model
            ]
        ]


goPanelView : Config msg -> Model -> Html msg
goPanelView config model =
    if config.showPassword then
        loginForm config model
    else
        togglePanel config


loginForm : Config msg -> Model -> Html msg
loginForm config model =
    let
        inputText =
            Maybe.withDefault "" model.password
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
                            Login model.target inputText
                    ]
                    [ text "E" ]
                ]
            ]


togglePanel : Config msg -> Html msg
togglePanel { onEnterPanel } =
    div [ onClick onEnterPanel ]
        [ text "E" ]
        |> List.singleton
        |> div []


crackBtn : Config msg -> Model -> Html msg
crackBtn config model =
    div
        [ onClick <| config.onCommonAction <| Crack model.target
        ]
        [ text "C"
        , br [] []
        , text "Crack"
        ]


anyMapBtn : Config msg -> Model -> Html msg
anyMapBtn config model =
    div
        [ onClick <| config.onCommonAction <| AnyMap model.target
        ]
        [ text "M"
        , br [] []
        , text "AnyMap"
        ]
