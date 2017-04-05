module Apps.Landing.View exposing (view)


import Html exposing (..)
import Html.Attributes exposing (..)

import Core.Models exposing (Model)
import Core.Messages exposing (Msg(MsgSignUp, MsgLogin))
import Apps.Login.View
import Apps.SignUp.View


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
    Html.map MsgLogin (Apps.Login.View.view model.appLogin model.game)


viewSignUp : Model -> Html Msg
viewSignUp model =
    Html.map MsgSignUp (Apps.SignUp.View.view model.appSignUp model.game)
