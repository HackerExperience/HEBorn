module Core.Subscriptions exposing (subscriptions)

import Driver.Websocket.Subscriptions
import Core.Messages exposing (CoreMsg(MsgOS, MsgApp, MsgWebsocket))
import Core.Models exposing (CoreModel)
import OS.Subscriptions
import Apps.Subscriptions


subscriptions : CoreModel -> Sub CoreMsg
subscriptions model =
    Sub.batch
        [ Sub.map MsgWebsocket
            (Driver.Websocket.Subscriptions.subscriptions model.websocket model)
        , Sub.map MsgOS
            (OS.Subscriptions.subscriptions model.os model)
        , Sub.map MsgApp
            (Apps.Subscriptions.subscriptions model.apps model)
        ]
