module Core.Subscriptions exposing (subscriptions)

import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Models exposing (GameModel)
import Game.Subscriptions as Game
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

        gameSub =
            game model model.game
    in
        Sub.batch
            [ osSub
            , websocketSub
            , gameSub
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


game : CoreModel -> GameModel -> Sub CoreMsg
game core game =
    core
        |> Game.subscriptions game
        |> Sub.map MsgGame
