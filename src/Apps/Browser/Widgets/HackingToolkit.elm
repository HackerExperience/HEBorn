module Apps.Browser.Widgets.HackingToolkit
    exposing
        ( Config
        , Password
        , Address
        , State
        , hackingToolkit
        , updateState
        )

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Network.Types exposing (NIP)
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(..))


type alias Config msg =
    { onInput : String -> msg
    , onCommonAction : CommonActions -> msg
    }


type alias Password =
    Maybe String


type alias Address =
    String


type alias State =
    { password : Maybe String
    , target : NIP
    }


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


hackingToolkit : Config msg -> State -> Html msg
hackingToolkit config state =
    div []
        [ loginForm config state
        , div [ class [ LoginPageFooter ] ]
            [ crackBtn config state
            , anyMapBtn config state
            ]
        ]


loginForm : Config msg -> State -> Html msg
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
                , text "E"
                ]
            ]


crackBtn : Config msg -> State -> Html msg
crackBtn config state =
    div
        [ onClick <| config.onCommonAction <| Crack state.target
        ]
        [ text "C"
        , br [] []
        , text "Crack"
        ]


anyMapBtn : Config msg -> State -> Html msg
anyMapBtn config state =
    div
        [ onClick <| config.onCommonAction <| AnyMap state.target
        ]
        [ text "M"
        , br [] []
        , text "AnyMap"
        ]


updateState : String -> State -> State
updateState password state =
    let
        newPassword =
            if password == "" then
                Nothing
            else
                Just password
    in
        { state | password = newPassword }
