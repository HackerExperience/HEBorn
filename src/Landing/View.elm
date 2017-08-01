module Landing.View exposing (view)

import Html exposing (..)
import Html.CssHelpers
import Core.Models as Core
import Landing.Messages exposing (..)
import Landing.Models exposing (..)
import Landing.Login.View as Login
import Landing.SignUp.View as SignUp
import Landing.Resources exposing (..)


{ id, class, classList } =
    Html.CssHelpers.withNamespace prefix


view : Core.Model -> Model -> Html Msg
view core model =
    div [ id viewId ]
        [ viewIntro
        , viewDisplayManager core model
        ]



-- internals


viewIntro : Html Msg
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


viewDisplayManager : Core.Model -> Model -> Html Msg
viewDisplayManager core model =
    div
        [ id displayManagerId
        , class
            (if core.windowLoaded then
                [ Loaded ]
             else
                []
            )
        ]
        [ viewLogin model
        , viewSignUp core model
        ]


viewLogin : Model -> Html Msg
viewLogin model =
    Html.map LoginMsg
        (Login.view model.login)


viewSignUp : Core.Model -> Model -> Html Msg
viewSignUp core model =
    if core.config.version == "dev" then
        Html.map SignUpMsg (SignUp.view model.signUp)
    else
        div [] []
