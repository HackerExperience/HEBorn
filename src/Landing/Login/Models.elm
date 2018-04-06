module Landing.Login.Models exposing (..)


type alias FormError =
    { usernameErrors : String
    , passwordErrors : String
    }


type alias Model =
    { formErrors : FormError
    , username : String
    , password : String
    , loginFailed : Maybe Errors
    }


type Errors
    = WrongCreds
    | NetworkError
    | HangTheDJ


initialErrors : FormError
initialErrors =
    { usernameErrors = ""
    , passwordErrors = ""
    }


initialModel : Model
initialModel =
    { formErrors = initialErrors
    , username = ""
    , password = ""
    , loginFailed = Nothing
    }
