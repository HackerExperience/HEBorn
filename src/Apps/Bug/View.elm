module Apps.Bug.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Html.Events exposing (onClick)
import Apps.Bug.Config exposing (..)
import Apps.Bug.Messages exposing (Msg(..))
import Apps.Bug.Models exposing (..)
import Apps.Bug.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    Html.map config.toMsg <|
        div []
            [ ul []
                [ li [] [ button [ onClick DummyToast ] [ text "Spawn useless toast" ] ]
                , li [] [ button [ onClick UnpoliteCrash ] [ text "Test unpolite crash" ] ]
                , li [] [ button [ onClick PoliteCrash ] [ text "Test polite crash" ] ]
                ]
            ]
