module OS.Subscriptions exposing (subscriptions)

import Core.Models exposing (CoreModel)
import OS.Models exposing (Model)
import OS.Messages exposing (OSMsg(MsgWM, ContextMsg))
import OS.Context.Subscriptions as OSContext
import OS.WindowManager.Subscriptions as WindowManager


subscriptions : Model -> CoreModel -> Sub OSMsg
subscriptions model core =
    Sub.batch
        [ Sub.map ContextMsg (OSContext.subscriptions model.context)
        , Sub.map MsgWM (WindowManager.subscriptions model.wm core)
        ]
