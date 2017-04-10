module Apps.Models exposing (AppModel, initialModel)

import Apps.Explorer.Models
import Apps.Login.Models
import Apps.SignUp.Models


type alias AppModel =
    { login : Apps.Login.Models.Model
    , signUp : Apps.SignUp.Models.Model
    , explorer : Apps.Explorer.Models.Model
    }


initialModel : AppModel
initialModel =
    { login = Apps.Login.Models.initialModel
    , signUp = Apps.SignUp.Models.initialModel
    , explorer = Apps.Explorer.Models.initialModel
    }
