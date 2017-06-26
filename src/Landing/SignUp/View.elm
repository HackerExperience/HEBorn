module Landing.SignUp.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Landing.SignUp.Messages exposing (Msg(..))
import Landing.SignUp.Models exposing (Model)


view : Model -> Html Msg
view model =
    div []
        [ Html.form
            [ id "signup-form"
            , action "javascript:void(0);"
            ]
            [ h1 [] [ text "Sign up" ]
            , label [ for "email-field" ] [ text "email: " ]
            , input
                [ id "email-field"
                , type_ "text"
                , value model.email
                , onInput (\str -> SetEmail str)
                , onBlur ValidateEmail
                ]
                []
            , div [ class "validation-error" ] [ text (viewErrorsEmail model) ]
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
            , button [ class ("signup-button " ++ signUpButtonClass model), onClick SubmitForm ] [ text "Sign up" ]
            ]
        ]


viewErrorsEmail : Model -> String
viewErrorsEmail model =
    model.formErrors.emailErrors


viewErrorsUsername : Model -> String
viewErrorsUsername model =
    if model.usernameTaken then
        "Username already taken"
    else
        model.formErrors.usernameErrors


viewErrorsPassword : Model -> String
viewErrorsPassword model =
    model.formErrors.passwordErrors


signUpButtonClass : Model -> String
signUpButtonClass model =
    if model.formErrors.usernameErrors /= "" || model.formErrors.passwordErrors /= "" then
        "disabled"
    else
        ""
