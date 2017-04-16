module OS.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import Core.Models exposing (CoreModel)
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (Model)


subscriptions : Model -> CoreModel -> Sub Msg
subscriptions model core =
    Sub.batch
        [ Draggable.subscriptions DragMsg model.drag
        ]
