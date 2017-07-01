module OS.Models exposing (Model, initialModel)

import Game.Data as GameData
import OS.SessionManager.Models as SessionManager
import OS.Header.Models as Header
import OS.Menu.Models as Menu


type alias Model =
    { session : SessionManager.Model
    , header : Header.Model
    , menu : Menu.Model
    }


initialModel : Model
initialModel =
    { session = SessionManager.initialModel
    , header = Header.initialModel
    , menu = Menu.initialContext
    }
