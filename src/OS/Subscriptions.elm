module OS.Subscriptions exposing (subscriptions)

import OS.WindowManager.Models as WindowManager
import OS.WindowManager.Subscriptions as WindowManager
import OS.Config exposing (..)
import OS.Models exposing (..)


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    windowManager config model.windowManager



-- internals


windowManager : Config msg -> WindowManager.Model -> Sub msg
windowManager config model =
    WindowManager.subscriptions (windowManagerConfig config) model
