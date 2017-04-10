module Core.Subscriptions exposing (subscriptions)

import WebSocket
import Core.Messages exposing (CoreMsg(WSReceivedMessage, MsgOS, MsgApp))
import Core.Models exposing (CoreModel)
import OS.WindowManager.Subscriptions
import Apps.Subscriptions


subscriptions : CoreModel -> Sub CoreMsg
subscriptions model =
    Sub.batch
        [ WebSocket.listen "ws://localhost:8080" WSReceivedMessage
        , Sub.map MsgOS (OS.WindowManager.Subscriptions.subscriptions model.os.wm model)
        , Sub.map MsgApp (Apps.Subscriptions.subscriptions model.apps model)
        ]
