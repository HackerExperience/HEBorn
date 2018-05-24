module OS.Subscriptions exposing (subscriptions)

import Core.Flags as Flags exposing (Flags)
import OS.Map.Subscriptions as Map
import OS.WindowManager.Models as WindowManager
import OS.WindowManager.Subscriptions as WindowManager
import OS.Config exposing (..)
import OS.Models exposing (..)


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    let
        windowSub =
            WindowManager.subscriptions (windowManagerConfig config)
                model.windowManager

        mapSub =
            if Flags.isHE2 config.flags then
                Map.subscriptions (mapConfig config) (getMap model)
            else
                Sub.none
    in
        Sub.batch
            [ windowSub
            , mapSub
            ]
