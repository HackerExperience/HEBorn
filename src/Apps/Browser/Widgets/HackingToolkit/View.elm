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
    div [ class [ HackingToolkit ] ] <|
        if config.showPassword then
            [ goPanelView config model
            , node "actions"
                []
                [ crackBtn config model
                , anyMapBtn config model
                ]
            ]
        else
            [ node "portal" [] [ text "Already logged!" ]
            , node "actions"
                []
                [ toggleBtn config ]
            ]


goPanelView : Config msg -> Model -> Html msg
goPanelView config model =
    loginForm config model


loginForm : Config msg -> Model -> Html msg
loginForm config model =
    let
        inputText =
            Maybe.withDefault "" model.password
    in
        node "portal"
            []
            [ div []
                [ input
                    [ placeholder "Password"
                    , value inputText
                    , onInput config.onInput
                    ]
                    []
                , button
                    [ inputText
                        |> Login model.target
                        |> config.onCommonAction
                        |> onClick
                    ]
                    [ text "Go" ]
                ]
            ]


toggleBtn : Config msg -> Html msg
toggleBtn { onEnterPanel } =
    div
        [ onClick onEnterPanel
        ]
        [ text "A"
        , br [] []
        , text "Painel"
        ]


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
