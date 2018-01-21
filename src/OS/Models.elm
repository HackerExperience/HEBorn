module OS.Models exposing (..)

import OS.SessionManager.Models as SessionManager
import OS.Header.Models as Header
import OS.Toasts.Models as Toasts


type alias Model =
    { session : SessionManager.Model
    , header : Header.Model
    , toasts : Toasts.Model
    }


initialModel : Model
initialModel =
    { session = SessionManager.initialModel
    , header = Header.initialModel
    , toasts = Toasts.initialModel
    }


getSessionManager : Model -> SessionManager.Model
getSessionManager =
    .session


setSessionManager : SessionManager.Model -> Model -> Model
setSessionManager sm model =
    { model | session = sm }


getHeader : Model -> Header.Model
getHeader =
    .header


setHeader : Header.Model -> Model -> Model
setHeader header model =
    { model | header = header }
