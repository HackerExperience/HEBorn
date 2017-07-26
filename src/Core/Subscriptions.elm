module Core.Subscriptions exposing (subscriptions)

import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Models as Game
import Game.Data as Game
import Game.Subscriptions as Game
import Driver.Websocket.Models as Ws
import Driver.Websocket.Subscriptions as Ws
import OS.Models as OS
import OS.Subscriptions as OS


subscriptions : Model -> Sub Msg
subscriptions ({ state } as model) =
    case state of
        Home homeModel ->
            home homeModel

        Setup setupModel ->
            setup setupModel

        Play playModel ->
            play playModel



-- internals


home : HomeModel -> Sub Msg
home model =
    case model.websocket of
        Just model ->
            websocket model

        Nothing ->
            Sub.none


setup : SetupModel -> Sub Msg
setup model =
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
    case Game.fromGateway game of
        Just data ->
            model
                |> OS.subscriptions data
                |> Sub.map OSMsg

        Nothing ->
            Sub.none


websocket : Ws.Model -> Sub Msg
websocket model =
    model
        |> Ws.subscriptions
        |> Sub.map WebsocketMsg


game : Game.Model -> Sub Msg
game game =
    game
        |> Game.subscriptions
        |> Sub.map GameMsg
