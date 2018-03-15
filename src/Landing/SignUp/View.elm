module Landing.SignUp.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput, onBlur)
import Html.CssHelpers
import Landing.Resources as R
import Landing.SignUp.Messages exposing (..)
import Landing.SignUp.Models exposing (..)


landClass : List class -> Attribute msg
landClass =
    (.class) <| Html.CssHelpers.withNamespace R.prefix


view : (Msg -> msg) -> Model -> Html msg
view toMsg model =
    div []
        [ Html.form
            [ id "signup-form"
            , action "javascript:void(0);"
            ]
            [ div [ landClass [ R.Title ] ] [ text "Sign up" ]
            , br [] []
            , div [ landClass [ R.Input ] ]
                [ label [ for "email-field" ] [ text "email: " ]
                , input
                    [ type_ "text"
                    , value model.email
                    , onInput (\str -> SetEmail str)
                    , onBlur ValidateEmail
                    ]
                    []
                ]
            , div [ class "validation-error" ] [ text (viewErrorsEmail model) ]
            , div [ landClass [ R.Input ] ]
                [ label [ for "username-field" ] [ text "username: " ]
                , input
                    [ type_ "text"
                    , value model.username
                    , onInput (\str -> SetUsername str)
                    , onBlur ValidateUsername
                    ]
                    []
                ]
            , div [ class "validation-error" ] [ text (viewErrorsUsername model) ]
            , div [ landClass [ R.Input ] ]
                [ label [ for "password-field" ] [ text "password: " ]
                , input
                    [ type_ "password"
                    , value model.password
                    , onInput (\str -> SetPassword str)
                    , onBlur ValidatePassword
                    ]
                    []
                ]
            , div [ class "validation-error" ] [ text (viewErrorsPassword model) ]
            , br [] []
            , button [ class ("signup-button " ++ signUpButtonClass model), onClick SubmitForm ] [ text "Sign up" ]
            ]
        ]
        |> Html.map toMsg


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
