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
import Apps.Browser.Widgets.HackingToolkit.Model exposing (..)
import Game.Meta.Types.Network exposing (NIP)


type alias Config msg =
    { onInput : String -> msg
    , onLogin : NIP -> String -> msg
    , onCrack : NIP -> msg
    , onAnyMap : NIP -> msg
    , onEnterPanel : msg
    , showPassword : Bool
    , fallbackPassword : Maybe String
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
loginForm config { target, password } =
    let
        inputText =
            case ( password, config.fallbackPassword ) of
                ( Just psw, _ ) ->
                    psw

                ( Nothing, Just fallback ) ->
                    fallback

                _ ->
                    ""
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
                        |> config.onLogin target
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
crackBtn { onCrack } model =
    div
        [ onClick <| onCrack model.target
        ]
        [ text "C"
        , br [] []
        , text "Crack"
        ]


anyMapBtn : Config msg -> Model -> Html msg
anyMapBtn { onAnyMap } model =
    div
        [ onClick <| onAnyMap model.target
        ]
        [ text "M"
        , br [] []
        , text "AnyMap"
        ]
