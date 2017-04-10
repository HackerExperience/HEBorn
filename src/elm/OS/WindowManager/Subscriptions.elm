module OS.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import Core.Models exposing (CoreModel)
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (Model)


subscriptions : Model -> CoreModel -> Sub OSMsg
subscriptions model core =
    Sub.batch
        [ Sub.map MsgWM (Draggable.subscriptions DragMsg model.drag)
        ]
