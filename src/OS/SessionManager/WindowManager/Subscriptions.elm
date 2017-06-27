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
appSubcriptions data model =
    model.windows
        |> Dict.toList
        |> List.filter (\( _, window ) -> window.state == NormalState)
        |> List.map
            (\( windowID, window ) ->
                window
                    |> getAppModel
                    |> Apps.subscriptions data
                    |> Sub.map (WindowMsg windowID)
            )
        |> Sub.batch
