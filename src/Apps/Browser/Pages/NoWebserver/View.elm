module Apps.Browser.Pages.NoWebserver.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Html.CssHelpers
import Game.Data as Game
import Apps.Browser.Resources exposing (Classes(..), prefix)
import Apps.Browser.Pages.CommonActions exposing (CommonActions(Crack))
import Apps.Browser.Pages.NoWebserver.Messages exposing (Msg(..))
import Apps.Browser.Pages.NoWebserver.Models exposing (Model)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Game.Data -> Model -> Html Msg
view data model =
    div [ class [ AutoHeight ] ]
        [ div [ class [ LoginPageHeader ] ] [ text "No web server running" ]
        , div [ class [ LoginPageForm ] ]
            [ div []
                [ passwordInput model.password
                , text "E"
                ]
            ]
        , div [ class [ LoginPageFooter ] ]
            [ crackBtn model.url
            , div []
                [ text "M"
                , br [] []
                , text "AnyMap"
                ]
            ]
        ]


crackBtn : String -> Html Msg
crackBtn target =
    div
        [ onClick <| GlobalMsg <| Crack target
        ]
        [ text "C"
        , br [] []
        , text "Crack"
        ]


passwordInput : Maybe String -> Html Msg
passwordInput psw =
    -- TODO: Hide when already on Endpoints
    let
        value_ =
            psw
                |> Maybe.withDefault ""
                |> value

        onInput_ =
            onInput UpdatePasswordField
    in
        input [ placeholder "Password", value_, onInput_ ] []
