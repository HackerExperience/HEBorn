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
    case model of
        Home model ->
            home model

        Play model ->
            play model



-- internals


home : HomeModel -> Sub Msg
home model =
    case model.websocket of
        Just model ->
            websocket model

        Nothing ->
            Sub.none


play : PlayModel -> Sub Msg
play model =
    let
        websocketSub =
            websocket model.websocket

        gameSub =
            game model.game

        osSub =
            os model.game model.os
    in
        Sub.batch
            [ websocketSub
            , gameSub
            , osSub
            ]


os : Game.Model -> OS.Model -> Sub Msg
os game model =
    model
        |> OS.subscriptions game
        |> Sub.map OSMsg


websocket : Websocket.Model -> Sub Msg
websocket model =
    model
        |> Websocket.subscriptions
        |> Sub.map WebsocketMsg


game : Game.Model -> Sub Msg
game game =
    game
        |> Game.subscriptions
        |> Sub.map GameMsg
