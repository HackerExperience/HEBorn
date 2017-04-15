module Landing.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Core.Models exposing (CoreModel)
import Landing.Messages exposing (LandMsg(MsgSignUp, MsgLogin))
import Landing.Login.View
import Landing.SignUp.View


view : CoreModel -> Html LandMsg
view model =
    div [ id "view-landing" ]
        [ viewIntro
        , viewLogin model
        , viewSignUp model
        ]


viewIntro : Html LandMsg
viewIntro =
    div [ id "view-intro" ]
        [ text "welcome to raquer ispirienci!"
        ]


viewLogin : CoreModel -> Html LandMsg
viewLogin model =
    Html.map MsgLogin (Landing.Login.View.view model.landing.login model.game)


viewSignUp : CoreModel -> Html LandMsg
viewSignUp model =
    Html.map MsgSignUp (Landing.SignUp.View.view model.landing.signUp model.game)
