module App.SignUp.Models exposing (..)

type alias FormError =
    { username : String
    , password : String
    }

type alias Model =
    { formErrors : FormError
    , username : String
    , password : String
    , usernameTaken : Bool
    }

initialErrors : FormError
initialErrors =
    { username = ""
    , password = ""
    }

initialModel : Model
initialModel =
    { formErrors = initialErrors
    , username = ""
    , password = ""
    , usernameTaken = False
    }
