module App.Landing.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)

import App.Models exposing (Model)
import App.Messages exposing (Msg(MsgSignUp, MsgLogin))
import App.Login.View
import App.SignUp.View

view : Model -> Html Msg
view model =
    div [ id "view-landing" ]
        [ viewIntro
        , viewLogin model
        , viewSignUp model
        ]

viewIntro : Html Msg
viewIntro =
    div [ id "view-intro"] [
         text "welcome to raquer ispirienci!"
    ]

viewLogin : Model -> Html Msg
viewLogin model =
    Html.map MsgLogin (App.Login.View.view model.appLogin model.core)

viewSignUp : Model -> Html Msg
viewSignUp model =
    Html.map MsgSignUp (App.SignUp.View.view model.appSignUp model.core)
