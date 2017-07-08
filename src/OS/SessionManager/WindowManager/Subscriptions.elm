module OS.SessionManager.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import Dict
import Game.Data as Game
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))
import OS.SessionManager.WindowManager.Models exposing (..)
import Apps.Subscriptions as Apps


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
                        |> Apps.subscriptions data
                        |> Sub.map (WindowMsg id)
                        |> Just

                Nothing ->
                    Nothing
    in
        visible
            |> List.filterMap mapper
            |> Sub.batch
