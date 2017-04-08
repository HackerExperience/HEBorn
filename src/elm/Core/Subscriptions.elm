module Core.Subscriptions exposing (subscriptions)


import WebSocket

import Core.Messages exposing (CoreMsg(WSReceivedMessage, MsgOS))
import Core.Models exposing (Model)

import OS.WindowManager.Subscriptions


subscriptions : Model -> Sub CoreMsg
subscriptions model =
    Sub.batch
        [ WebSocket.listen "ws://localhost:8080" WSReceivedMessage
        , Sub.map MsgOS (OS.WindowManager.Subscriptions.subscriptions model.os.wm)
        ]
