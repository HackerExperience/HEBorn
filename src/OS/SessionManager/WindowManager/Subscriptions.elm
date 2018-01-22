module OS.SessionManager.WindowManager.Subscriptions exposing (subscriptions)

import Dict
import Draggable
import Apps.Subscriptions as Apps
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))
import OS.SessionManager.WindowManager.Models exposing (..)


subscriptions : Config msg -> Model -> Sub msg
subscriptions config model =
    Sub.batch
        [ Draggable.subscriptions (DragMsg >> config.toMsg) model.drag
        , appSubcriptions config model
        ]



appSubcriptions : Config msg -> Model -> Sub msg
appSubcriptions config ({ visible, windows } as model) =
    let
        context window =
            Just (windowContext window)

        config_ id window =
            appsConfig (context window) id Active config

        mapper id =
            case Dict.get id windows of
                Just window ->
                    window
                        |> getAppModelFromWindow
                        |> Apps.subscriptions (config_ id window)
                        |> Just

                Nothing ->
                    Nothing
    in
        visible
            |> List.filterMap mapper
            |> Sub.batch
