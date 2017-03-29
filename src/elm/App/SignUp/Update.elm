module App.SignUp.Update exposing (..)


import App.SignUp.Models exposing (Model, FormError)
import App.SignUp.Messages exposing (Msg(..))
import App.SignUp.Requests exposing (responseHandler
                                    , requestSignUp, requestSignUpHandler
                                    -- , requestUsernameExists
                                    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SubmitForm ->
            let
                formErrors = getErrors model
                cmd = requestSignUp model.email model.username model.password
            in
                (model, cmd)

        SetUsername username ->
            ({ model | username = username, usernameTaken = False}, Cmd.none)

        ValidateUsername ->
            let
                {usernameErrors, passwordErrors, emailErrors} = model.formErrors
                newUsernameErrors = getErrorsUsername model
                newFormErrors = { usernameErrors = newUsernameErrors, passwordErrors = passwordErrors, emailErrors = emailErrors}
            in
                ({ model | formErrors = newFormErrors}, Cmd.none)

        SetPassword password ->
            ({ model | password = password}, Cmd.none)

        ValidatePassword ->
            let
                {usernameErrors, passwordErrors, emailErrors} = model.formErrors
                newPasswordErrors = getErrorsPassword model
                newFormErrors = { usernameErrors = usernameErrors, passwordErrors = newPasswordErrors, emailErrors = emailErrors}
            in
                ({ model | formErrors = newFormErrors}, Cmd.none)

        SetEmail email ->
            ({ model | email = email}, Cmd.none)

        ValidateEmail ->
            let
                {usernameErrors, passwordErrors, emailErrors} = model.formErrors
                newEmailErrors = getErrorsEmail model
                newFormErrors = { usernameErrors = usernameErrors, passwordErrors = passwordErrors, emailErrors = newEmailErrors}
            in
                ({ model | formErrors = newFormErrors}, Cmd.none)


        Event event ->
            case event of
                _ ->
                    (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            responseHandler request data model


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

getErrorsEmail: Model -> String
getErrorsEmail model =
    if model.email == "" then
        "Enter email"
    else
        ""


getErrors : Model -> FormError
getErrors model =
    let
        usernameErrors = getErrorsUsername model
        passwordErrors = getErrorsPassword model
        emailErrors = getErrorsEmail model
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
        {usernameErrors, passwordErrors, emailErrors} = getErrors model
    in
        case (usernameErrors, passwordErrors, emailErrors) of
            ("", "", "") ->
                False
            _ ->
                True
