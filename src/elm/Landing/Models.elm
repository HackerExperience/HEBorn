module Landing.Models exposing (LandModel, initialModel)

import Landing.Login.Models
import Landing.SignUp.Models


type alias LandModel =
    { login : Landing.Login.Models.Model
    , signUp : Landing.SignUp.Models.Model
    }


initialModel : LandModel
initialModel =
    { login = Landing.Login.Models.initialModel
    , signUp = Landing.SignUp.Models.initialModel
    }
