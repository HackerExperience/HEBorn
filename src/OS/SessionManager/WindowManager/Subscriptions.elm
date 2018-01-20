module OS.SessionManager.WindowManager.Subscriptions exposing (subscriptions)

import Dict
import Draggable
import Game.Data as Game
import Apps.Subscriptions as Apps
import OS.SessionManager.WindowManager.Config exposing (..)
import OS.SessionManager.WindowManager.Helpers exposing (..)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))
import OS.SessionManager.WindowManager.Models exposing (..)


subscriptions : Config msg -> Game.Data -> Model -> Sub msg
subscriptions config data model =
    Sub.batch
        [ Draggable.subscriptions (DragMsg >> config.toMsg) model.drag
        , appSubcriptions config data model
        ]



--CONFREFACT : Remove Game.Data from here after refactor


appSubcriptions : Config msg -> Game.Data -> Model -> Sub msg
appSubcriptions config data ({ visible, windows } as model) =
    let
        config_ id =
            appsConfig id Active config

        mapper id =
            case Dict.get id windows of
                Just window ->
                    window
                        |> getAppModelFromWindow
                        |> Apps.subscriptions (config_ id) (windowData config data Nothing id window model)
                        |> Just

                Nothing ->
                    Nothing
    in
        visible
            |> List.filterMap mapper
            |> Sub.batch
