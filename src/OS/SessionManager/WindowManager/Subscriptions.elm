module OS.SessionManager.WindowManager.Subscriptions exposing (subscriptions)

import Dict
import Draggable
import Game.Data as Game
import Apps.Subscriptions as Apps
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))
import OS.SessionManager.WindowManager.Models exposing (..)


subscriptions : Game.Data -> Model -> Sub Msg
subscriptions data model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , appSubcriptions data model
        ]


appSubcriptions : Game.Data -> Model -> Sub Msg
appSubcriptions data ({ visible, windows } as model) =
    let
        mapper id =
            case Dict.get id windows of
                Just window ->
                    window
                        |> getAppModelFromWindow
                        |> Apps.subscriptions (windowData data id window model)
                        |> Sub.map (WindowMsg id)
                        |> Just

                Nothing ->
                    Nothing
    in
        visible
            |> List.filterMap mapper
            |> Sub.batch
