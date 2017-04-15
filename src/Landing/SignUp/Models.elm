module Landing.SignUp.Models exposing (..)


type alias FormError =
    { usernameErrors : String
    , passwordErrors : String
    , emailErrors : String
    }


type alias Model =
    { formErrors : FormError
    , username : String
    , password : String
    , email : String
    , usernameTaken : Bool
    }


initialErrors : FormError
initialErrors =
    { usernameErrors = ""
    , passwordErrors = ""
    , emailErrors = ""
    }


initialModel : Model
initialModel =
    { formErrors = initialErrors
    , username = ""
    , password = ""
    , email = ""
    , usernameTaken = False
    }
