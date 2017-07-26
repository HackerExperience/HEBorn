module Landing.SignUp.Update exposing (update)

import Landing.SignUp.Models exposing (Model, FormError)
import Landing.SignUp.Messages exposing (Msg(..))
import Landing.SignUp.Requests exposing (..)
import Landing.SignUp.Requests.SignUp as SignUp
import Core.Models as Core
import Core.Dispatch as Dispatch exposing (Dispatch)


update : Core.Model -> Msg -> Model -> ( Model, Cmd Msg, Dispatch )
update core msg model =
    case msg of
        SubmitForm ->
            let
                cmd =
                    SignUp.request
                        model.email
                        model.username
                        model.password
                        core
            in
                ( model, cmd, Dispatch.none )

        SetUsername username ->
            ( { model | username = username, usernameTaken = False }, Cmd.none, Dispatch.none )

        ValidateUsername ->
            let
                { usernameErrors, passwordErrors, emailErrors } =
                    model.formErrors

                newUsernameErrors =
                    getErrorsUsername model

                newFormErrors =
                    { usernameErrors = newUsernameErrors, passwordErrors = passwordErrors, emailErrors = emailErrors }
            in
                ( { model | formErrors = newFormErrors }, Cmd.none, Dispatch.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none, Dispatch.none )

        ValidatePassword ->
            let
                { usernameErrors, passwordErrors, emailErrors } =
                    model.formErrors

                newPasswordErrors =
                    getErrorsPassword model

                newFormErrors =
                    { usernameErrors = usernameErrors, passwordErrors = newPasswordErrors, emailErrors = emailErrors }
            in
                ( { model | formErrors = newFormErrors }, Cmd.none, Dispatch.none )

        SetEmail email ->
            ( { model | email = email }, Cmd.none, Dispatch.none )

        ValidateEmail ->
            let
                { usernameErrors, passwordErrors, emailErrors } =
                    model.formErrors

                newEmailErrors =
                    getErrorsEmail model

                newFormErrors =
                    { usernameErrors = usernameErrors, passwordErrors = passwordErrors, emailErrors = newEmailErrors }
            in
                ( { model | formErrors = newFormErrors }, Cmd.none, Dispatch.none )

        Request data ->
            response core (receive data) model



-- internals


response :
    Core.Model
    -> Response
    -> Model
    -> ( Model, Cmd Msg, Dispatch )
response core response model =
    case response of
        -- TODO: add more types to match response status
        SignUpResponse (SignUp.OkResponse _ _ _) ->
            ( model, Cmd.none, Dispatch.none )

        _ ->
            ( model, Cmd.none, Dispatch.none )


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


getErrors : Model -> FormError
getErrors model =
    let
        usernameErrors =
            getErrorsUsername model

        passwordErrors =
            getErrorsPassword model

        emailErrors =
            getErrorsEmail model
    in
        { usernameErrors = usernameErrors, passwordErrors = passwordErrors, emailErrors = emailErrors }


hasErrorsUsername : Model -> Bool
hasErrorsUsername model =
    case (getErrorsUsername model) of
        "" ->
            False

        _ ->
            True


hasErrors : Model -> Bool
hasErrors model =
    let
        { usernameErrors, passwordErrors, emailErrors } =
            getErrors model
    in
        case ( usernameErrors, passwordErrors, emailErrors ) of
            ( "", "", "" ) ->
                False

            _ ->
                True
