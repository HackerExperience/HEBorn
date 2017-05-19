module OS.Subscriptions exposing (subscriptions)

import Core.Models exposing (CoreModel)
import OS.Models exposing (Model)
import OS.Messages exposing (OSMsg(MsgWM, ContextMenuMsg))
import OS.Menu.Subscriptions as OSMenu
import OS.WindowManager.Subscriptions as WindowManager


subscriptions : Model -> CoreModel -> Sub OSMsg
subscriptions model core =
    Sub.batch
        [ Sub.map ContextMenuMsg (OSMenu.subscriptions model.context)
        , Sub.map MsgWM (WindowManager.subscriptions model.wm core)
        ]
