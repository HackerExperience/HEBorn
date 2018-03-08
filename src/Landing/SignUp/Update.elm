module Landing.SignUp.Update exposing (update)

import Utils.React as React exposing (React)
import Landing.Requests.SignUp as SignUpRequest exposing (signUpRequest)
import Landing.SignUp.Config exposing (..)
import Landing.SignUp.Messages exposing (..)
import Landing.SignUp.Models exposing (..)


type alias UpdateResponse msg =
    ( Model, React msg )


update : Config msg -> Msg -> Model -> UpdateResponse msg
update config msg model =
    case msg of
        SubmitForm ->
            ( model
            , config
                |> signUpRequest model.email model.username model.password
                |> Cmd.map (SignUpRequest >> config.toMsg)
                |> React.cmd
            )

        SetUsername username ->
            ( { model | username = username, usernameTaken = False }
            , React.none
            )

        ValidateUsername ->
            let
                { usernameErrors, passwordErrors, emailErrors } =
                    model.formErrors

                newUsernameErrors =
                    getErrorsUsername model

                newFormErrors =
                    { usernameErrors = newUsernameErrors, passwordErrors = passwordErrors, emailErrors = emailErrors }
            in
                ( { model | formErrors = newFormErrors }
                , React.none
                )

        SetPassword password ->
            ( { model | password = password }
            , React.none
            )

        ValidatePassword ->
            let
                { usernameErrors, passwordErrors, emailErrors } =
                    model.formErrors

                newPasswordErrors =
                    getErrorsPassword model

                newFormErrors =
                    { usernameErrors = usernameErrors, passwordErrors = newPasswordErrors, emailErrors = emailErrors }
            in
                ( { model | formErrors = newFormErrors }
                , React.none
                )

        SetEmail email ->
            ( { model | email = email }
            , React.none
            )

        ValidateEmail ->
            let
                { usernameErrors, passwordErrors, emailErrors } =
                    model.formErrors

                newEmailErrors =
                    getErrorsEmail model

                newFormErrors =
                    { usernameErrors = usernameErrors, passwordErrors = passwordErrors, emailErrors = newEmailErrors }
            in
                ( { model | formErrors = newFormErrors }
                , React.none
                )

        SignUpRequest data ->
            onSignUpRequest config data model



-- internals


onSignUpRequest :
    Config msg
    -> SignUpRequest.Data
    -> Model
    -> UpdateResponse msg
onSignUpRequest config data model =
    ( model, React.none )


getErrorsUsername : Model -> String
getErrorsUsername model =
    if model.username == "" then
        "Please specify a username"
    else if String.length model.username < 3 then
        "Username too small"
    else if String.length model.username >= 15 then
        "Username too big"
    else
        ""


getErrorsPassword : Model -> String
getErrorsPassword model =
    if model.password == "" then
        "Enter password"
    else if model.password == model.username then
        "Your password and username are the same..."
    else
        ""


getErrorsEmail : Model -> String
getErrorsEmail model =
    if model.email == "" then
        "Enter email"
    else
        ""
