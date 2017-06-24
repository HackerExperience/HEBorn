module Landing.Login.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Landing.Login.Messages exposing (Msg(..))
import Landing.Login.Models exposing (Model)


view : Model -> Html Msg
view model =
    Html.form
        [ id "login-form"
        , action "javascript:void(0);"
        ]
        [ h1 [] [ text "Login" ]
        , label [ for "username-field" ] [ text "username: " ]
        , input
            [ id "username-field"
            , type_ "text"
            , value model.username
            , onInput (\str -> SetUsername str)
            , onBlur ValidateUsername
            ]
            []
        , div [ class "validation-error" ] [ text (viewErrorsUsername model) ]
        , label [ for "password-field" ] [ text "password: " ]
        , input
            [ id "password-field"
            , type_ "password"
            , value model.password
            , onInput (\str -> SetPassword str)
            , onBlur ValidatePassword
            ]
            []
        , div [ class "validation-error" ] [ text (viewErrorsPassword model) ]
        , div [ class "login-error" ] [ text (viewErrorsLogin model) ]
        , button [ class ("signup-button " ++ buttonClass model), onClick SubmitLogin ] [ text "Login" ]
        ]


viewErrorsUsername : Model -> String
viewErrorsUsername model =
    model.formErrors.usernameErrors


viewErrorsPassword : Model -> String
viewErrorsPassword model =
    model.formErrors.passwordErrors


viewErrorsLogin : Model -> String
viewErrorsLogin model =
    if model.loginFailed then
        "Login failed"
    else
        ""


buttonClass : Model -> String
buttonClass model =
    if model.formErrors.usernameErrors /= "" || model.formErrors.passwordErrors /= "" then
        "disabled"
    else
        ""
