module OS.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (Model)
import OS.WindowManager.ContextHandler.Subscriptions as ContextHandler


subscriptions : Model -> Sub OSMsg
subscriptions model =
    Sub.batch
        [ Sub.map MsgWM (Draggable.subscriptions DragMsg model.drag)
        , Sub.map MsgWM (ContextHandler.subscriptions model.contextHandler)
        ]
