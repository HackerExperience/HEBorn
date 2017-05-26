module OS.SessionManager.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import Dict
import Game.Models exposing (GameModel)
import OS.SessionManager.WindowManager.Messages exposing (Msg(..))
import OS.SessionManager.WindowManager.Models exposing (..)
import Apps.Subscriptions as Apps


subscriptions : GameModel -> Model -> Sub Msg
subscriptions game model =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , appSubcriptions game model
        ]


appSubcriptions : GameModel -> Model -> Sub Msg
appSubcriptions game model =
    model.windows
        |> Dict.toList
        |> List.filter (\( _, window ) -> window.state == NormalState)
        |> List.map
            (\( windowID, window ) ->
                window
                    |> getAppModel
                    |> Apps.subscriptions game
                    |> Sub.map (WindowMsg windowID)
            )
        |> Sub.batch
