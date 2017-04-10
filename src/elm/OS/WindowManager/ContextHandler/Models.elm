module OS.WindowManager.ContextHandler.Models exposing (..)

import Apps.Explorer.Context.Models as Explorer
import Apps.SignUp.Context.Models as SignUp


type alias Model =
    { explorer : Explorer.ContextModel
    , signup : SignUp.ContextModel
    }


initialModel : Model
initialModel =
    { explorer = Explorer.initialContext
    , signup = SignUp.initialContext
    }
