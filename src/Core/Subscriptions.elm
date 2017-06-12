module Core.Subscriptions exposing (subscriptions)

import Driver.Websocket.Subscriptions
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Models exposing (GameModel)
import Driver.Websocket.Models as Websocket
import Driver.Websocket.Subscriptions as Websocket
import OS.Models as OS
import OS.Subscriptions as OS


subscriptions : CoreModel -> Sub CoreMsg
subscriptions model =
    let
        osSub =
            os model.game model.os

        websocketSub =
            websocket model model.websocket
    in
        Sub.batch
            [ osSub
            , websocketSub
            ]



-- internals


os : GameModel -> OS.Model -> Sub CoreMsg
os game model =
    model
        |> OS.subscriptions game
        |> Sub.map MsgOS


websocket : CoreModel -> Websocket.Model -> Sub CoreMsg
websocket core model =
    core
        |> Websocket.subscriptions model
        |> Sub.map MsgWebsocket
