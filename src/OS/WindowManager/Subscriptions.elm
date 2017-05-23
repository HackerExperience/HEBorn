module OS.WindowManager.Subscriptions exposing (subscriptions)

import Dict
import Draggable
import Core.Models exposing (CoreModel)
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (..)
import Apps.Subscriptions as Apps
import Apps.Messages as Apps


subscriptions : Model -> CoreModel -> Sub Msg
subscriptions model core =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        , appSubcriptions core model
        ]


appSubcriptions : CoreModel -> Model -> Sub Msg
appSubcriptions core model =
    model.windows
    |> Dict.values
    |> List.map
        (\window -> window |> getAppModel |> Apps.subscriptions core.game)
    |> Sub.batch
    |> Sub.map AppMsg
