module OS.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import Dict
import Core.Models exposing (CoreModel)
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (..)
import Apps.Subscriptions as Apps


subscriptions : Model -> CoreModel -> Sub Msg
subscriptions model core =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , appSubcriptions core model
        ]


appSubcriptions : CoreModel -> Model -> Sub Msg
appSubcriptions core model =
    model.windows
        |> Dict.toList
        |> List.filter (\( _, window ) -> window.state == NormalState)
        |> List.map
            (\( windowID, window ) ->
                window
                |> getAppModel
                |> Apps.subscriptions core.game
                |> Sub.map (WindowMsg windowID)
            )
        |> Sub.batch