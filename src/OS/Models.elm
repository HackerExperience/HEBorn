module OS.Models
    exposing
        ( Model
        , initialModel
        , getSessionManager
        , setSessionManager
        )

import OS.SessionManager.Models as SessionManager
import OS.Header.Models as Header
import OS.Menu.Models as Menu
import OS.Toasts.Models as Toasts


type alias Model =
    { session : SessionManager.Model
    , header : Header.Model
    , menu : Menu.Model
    , toasts : Toasts.Model
    }


initialModel : Model
initialModel =
    { session = SessionManager.initialModel
    , header = Header.initialModel
    , menu = Menu.initialContext
    , toasts = Toasts.initialModel
    }


getSessionManager : Model -> SessionManager.Model
getSessionManager =
    .session


setSessionManager : SessionManager.Model -> Model -> Model
setSessionManager sm model =
    { model | session = sm }
