module Landing.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Core.Models as Core
import Landing.Messages exposing (..)
import Landing.Login.View
import Landing.SignUp.View


view : Core.Model -> Html Msg
view model =
    div [ id "view-landing" ]
        [ viewIntro
        , viewLogin model
        , viewSignUp model
        ]


viewIntro : Html Msg
viewIntro =
    div [ id "view-intro" ]
        [ text "Shh! Don't tell anyone, but this is the new HE1 website."
        , br [] []
        , text "We are under active development, and soon we'll release the new HE1 to public."
        ]


viewLogin : Core.Model -> Html Msg
viewLogin model =
    Html.map LoginMsg (Landing.Login.View.view model.landing.login model.game)


viewSignUp : Core.Model -> Html Msg
viewSignUp model =
    if model.game.meta.config.version == "dev" then
        Html.map SignUpMsg (Landing.SignUp.View.view model.landing.signUp model.game)
    else
        div [] []
