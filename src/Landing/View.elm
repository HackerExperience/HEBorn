module Landing.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Landing.Login.View as Login
import Landing.SignUp.View as SignUp
import Landing.Config exposing (..)
import Landing.Messages exposing (..)
import Landing.Models exposing (..)
import Landing.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Config msg -> Model -> Html msg
view config model =
    div [ id viewId ]
        [ viewIntro
        , viewDisplayManager config model
        ]



-- internals


viewIntro : Html msg
viewIntro =
    div [ id introId ]
        [ text "Shh! Don't tell anyone, but this is the new HE1 website."
        , br [] []
        , text "We are under active development, and soon we'll release the new HE1 to public."
        , br [] []
        , br [] []
        , text "$ startx /usr/bin/hedm"
        , br [] []
        , text "Starting graphics server..."
        , br [] []
        , text "> Loading resources:"
        , br [] []
        , text ">> Fonts... OKAY"
        , br [] []
        , text ">> Icons... OKAY"
        , br [] []
        , text ">> Images... OKAY"
        , br [] []
        , text ">> Dashboard..."
        ]


viewDisplayManager : Config msg -> Model -> Html msg
viewDisplayManager config model =
    div
        [ id displayManagerId
        , class
            (if config.windowLoaded then
                [ Loaded ]
             else
                []
            )
        ]
        [ viewLogin config model
        , viewSignUp config model
        ]


viewLogin : Config msg -> Model -> Html msg
viewLogin config model =
    Login.view (.toMsg (loginConfig config)) model.login


viewSignUp : Config msg -> Model -> Html msg
viewSignUp config model =
    if config.flags.version == "dev" then
        SignUp.view (.toMsg (signupConfig config)) model.signUp
    else
        div [] []
