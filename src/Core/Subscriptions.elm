module Core.Subscriptions exposing (subscriptions)

import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Models as Game
import Game.Subscriptions as Game
import Driver.Websocket.Models as Websocket
import Driver.Websocket.Subscriptions as Websocket
import OS.Models as OS
import OS.Subscriptions as OS


subscriptions : Model -> Sub Msg
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


os : Game.Model -> OS.Model -> Sub Msg
os game model =
    model
        |> OS.subscriptions game
        |> Sub.map OSMsg


websocket : Model -> Websocket.Model -> Sub Msg
websocket core model =
    core
        |> Websocket.subscriptions model
        |> Sub.map WebsocketMsg


game : Model -> Game.Model -> Sub Msg
game core game =
    core
        |> Game.subscriptions game
        |> Sub.map GameMsg
