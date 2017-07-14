module Landing.View exposing (view)

import Html exposing (..)
import Html.Attributes exposing (..)
import Core.Models as Core
import Landing.Messages exposing (..)
import Landing.Login.View as Login
import Landing.SignUp.View as SignUp
import Landing.Resources exposing (..)


view : Core.HomeModel -> Html Msg
view model =
    div [ id viewId ]
        [ viewIntro
        , viewLogin model
        , viewSignUp model
        ]



-- internals


viewIntro : Html Msg
viewIntro =
    div [ id introId ]
        [ text "Shh! Don't tell anyone, but this is the new HE1 website."
        , br [] []
        , text "We are under active development, and soon we'll release the new HE1 to public."
        ]


viewLogin : Core.HomeModel -> Html Msg
viewLogin model =
    Html.map LoginMsg
        (Login.view model.landing.login)


viewSignUp : Core.HomeModel -> Html Msg
viewSignUp model =
    if model.config.version == "dev" then
        Html.map SignUpMsg
            (SignUp.view model.landing.signUp)
    else
        div [] []
