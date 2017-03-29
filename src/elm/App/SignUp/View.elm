module App.SignUp.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur, onWithOptions)
import App.SignUp.Messages exposing (Msg(..))
import App.SignUp.Models exposing (Model)


view : Model -> Html Msg
view model =
    Html.form
        [ id "signup-form"
        , action "javascript:void(0);"]
        [ h1 [] [ text "Sign up" ]
        , label [ for "username-field" ] [ text "username: " ]
        , input
             [ id "username-field"
             , type_ "text"
             , value model.username
             , onInput (\str -> SetUsername str)
             , onBlur ValidateUsername
             ] []
        , div [ class "validation-error" ] [ text (viewUsernameErrors model) ]
        , label [ for "password-field" ] [ text "password: " ]
        , input
             [ id "password-field"
             , type_ "password"
             , value model.password
             , onInput (\str -> SetPassword str)
             , onBlur ValidatePassword
             ] []
        , div [ class "validation-error"] [ text model.formErrors.password ]
        , button [ class ("signup-button " ++ signUpButtonClass model), onClick SubmitForm ] [ text "Sign up" ]
        ]

viewUsernameErrors : Model -> String
viewUsernameErrors model =
    if model.usernameTaken then
        "Username already taken"
    else
        model.formErrors.username

signUpButtonClass : Model -> String
signUpButtonClass model =
    if model.formErrors.username /= "" || model.formErrors.password /= "" then
        "disabled"
    else
        ""
