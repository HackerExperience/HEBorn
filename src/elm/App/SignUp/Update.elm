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
                formErrors = getErrors model "username"
                taken = if not (hasErrors model "username") then
                    True
                else
                    False
                cmd = requestSignUp model.username model.password
            in
                (model, cmd)


        SetUsername username ->
            ({ model | username = username, usernameTaken = False}, Cmd.none )

        ValidateUsername ->
            let
                formErrors = getErrors model "username"
                taken = if not (hasErrors model "username") then
                    True
                else
                    False
                cmd = requestSignUp model.username model.password
            in
                ({ model | formErrors = getErrors model "username"}, cmd)

        SetPassword password ->
            ({ model | password = password}, Cmd.none )

        ValidatePassword ->
            ({ model | formErrors = getErrors model "password"}, Cmd.none)

        FormSubmit (Ok result) ->
            ({ model | usernameTaken = True, formErrors = getErrors model "all"}, Cmd.none)

        FormSubmit (Err _) ->
            ({ model | username = "fail"}, Cmd.none)

        Event event ->
            case event of
                _ ->
                    (model, Cmd.none)

        Request _ ->
            (model, Cmd.none)

        Response request data ->
            responseHandler request data model


getUsernameErrors : Model -> String
getUsernameErrors model =
    if model.username == "" then
        "Enter username"
    else if String.length model.username < 3 then
        "Usenrame too smal"
    else
        ""


getPasswordErrors : Model -> String
getPasswordErrors model =
    if model.password == "" then
        "Enter password"
    else
        ""


getErrors : Model -> String -> FormError
getErrors model field =
    let
        username = getUsernameErrors model
        password = getPasswordErrors model
    in
        case field of
            "username" ->
                { username = username, password = model.formErrors.password }
            "password" ->
                { username = model.formErrors.username, password = password }
            _ ->
                { username = username, password = password }


hasErrors : Model -> String -> Bool
hasErrors model field =
    let
        {username, password} = getErrors model field
    in
        case (username, password) of
            ("", "") ->
                False
            _ ->
                True
