module Landing.Models exposing (Model, initialModel)

import Landing.Login.Models
import Landing.SignUp.Models


type alias Model =
    { login : Landing.Login.Models.Model
    , signUp : Landing.SignUp.Models.Model
    }


initialModel : Model
initialModel =
    { login = Landing.Login.Models.initialModel
    , signUp = Landing.SignUp.Models.initialModel
    }
