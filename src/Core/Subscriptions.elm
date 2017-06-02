module Core.Subscriptions exposing (subscriptions)

import Driver.Websocket.Subscriptions
import Core.Messages exposing (CoreMsg(MsgOS, MsgGame, MsgWebsocket))
import Core.Models exposing (CoreModel)
import OS.Subscriptions
import Game.Subscriptions


subscriptions : CoreModel -> Sub CoreMsg
subscriptions model =
    Sub.batch
        [ Sub.map MsgWebsocket
            (Driver.Websocket.Subscriptions.subscriptions model.websocket model)
        , Sub.map MsgOS
            (OS.Subscriptions.subscriptions model.os model)
        , Sub.map MsgGame
            (Game.Subscriptions.subscriptions model.game model)
        ]
