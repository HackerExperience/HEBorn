module Apps.SignUp.Models exposing (..)

import Apps.SignUp.Context.Models exposing (ContextModel, initialContext)


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
    , context : ContextModel
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
    , context = initialContext
    }
