module OS.WindowManager.Subscriptions exposing (subscriptions)

import Draggable
import OS.Messages exposing (OSMsg(..))
import OS.WindowManager.Messages exposing (Msg(..))
import OS.WindowManager.Models exposing (Model)


subscriptions : Model -> Sub OSMsg
subscriptions model =
    Sub.map MsgWM (Draggable.subscriptions DragMsg model.drag)
