module OS.Models exposing (..)

import Core.Flags as Flags exposing (Flags)
import OS.Map.Models as Map
import OS.WindowManager.Models as WindowManager
import OS.Header.Models as Header
import OS.Toasts.Models as Toasts


type alias Model =
    { windowManager : WindowManager.Model
    , header : Header.Model
    , toasts : Toasts.Model
    , map : Map.Model
    }


initialModel : Model
initialModel =
    { windowManager = WindowManager.initialModel
    , header = Header.initialModel
    , toasts = Toasts.initialModel
    , map = Map.initialModel
    }


startCmd : Flags -> Cmd msg
startCmd flags =
    if Flags.isHE2 flags then
        Map.startCmd
    else
        Cmd.none


getWindowManager : Model -> WindowManager.Model
getWindowManager =
    .windowManager


setWindowManager : WindowManager.Model -> Model -> Model
setWindowManager windowManager model =
    { model | windowManager = windowManager }


getHeader : Model -> Header.Model
getHeader =
    .header


setHeader : Header.Model -> Model -> Model
setHeader header model =
    { model | header = header }


getToasts : Model -> Toasts.Model
getToasts =
    .toasts


setToasts : Toasts.Model -> Model -> Model
setToasts toasts model =
    { model | toasts = toasts }


getMap : Model -> Map.Model
getMap =
    .map


setMap : Map.Model -> Model -> Model
setMap map model =
    { model | map = map }
