module App.Login.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import App.Login.Messages exposing (Msg(..))
import App.Login.Models exposing (Model)


view : Model -> Html Msg
view model =
    div []
        [ div [] [ text (toString model.errors) ]
        , button [ onClick SubmitLogin ] [ text "login" ]
        , a [ href ("#register") ] [ text "sign up" ]
        ]
