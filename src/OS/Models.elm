module OS.Models exposing (Model, initialModel)

import Game.Models as Game
import OS.SessionManager.Models as SessionManager
import OS.Header.Models as Header
import OS.Menu.Models as Menu


type alias Model =
    { session : SessionManager.Model
    , header : Header.Model
    , menu : Menu.Model
    }


initialModel : Game.Model -> Model
initialModel game =
    { session = SessionManager.initialModel game
    , header = Header.initialModel
    , menu = Menu.initialContext
    }
