module Apps.Landing.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Core.Models exposing (CoreModel)
import Apps.Messages exposing (AppMsg(MsgSignUp, MsgLogin))
import Apps.Login.View
import Apps.SignUp.View


view : CoreModel -> Html AppMsg
view model =
    div [ id "view-landing" ]
        [ viewIntro
        , viewLogin model
        , viewSignUp model
        ]


viewIntro : Html AppMsg
viewIntro =
    div [ id "view-intro" ]
        [ text "welcome to raquer ispirienci!"
        ]


viewLogin : CoreModel -> Html AppMsg
viewLogin model =
    Html.map MsgLogin (Apps.Login.View.view model.apps.login model.game)


viewSignUp : CoreModel -> Html AppMsg
viewSignUp model =
    Html.map MsgSignUp (Apps.SignUp.View.view model.apps.signUp model.game)
