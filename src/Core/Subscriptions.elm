module Core.Subscriptions exposing (subscriptions)

import Driver.Websocket.Subscriptions
import Core.Messages exposing (CoreMsg(MsgOS, MsgGame, MsgWebsocket))
import Core.Models exposing (CoreModel)
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
            game model.game
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


game : GameModel -> Sub CoreMsg
game game =
    core
        |> Game.subscriptions game
        |> Sub.map MsgGame
