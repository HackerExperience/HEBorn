module Core.Subscriptions exposing (subscriptions)

import Utils.Ports.OnLoad exposing (windowLoaded)
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Game.Models as Game
import Game.Data as Game
import Game.Subscriptions as Game
import Driver.Websocket.Models as Ws
import Driver.Websocket.Subscriptions as Ws
import Landing.Subscriptions as Landing
import OS.Models as OS
import OS.Subscriptions as OS
import Setup.Subscriptions as Setup


subscriptions : Model -> Sub Msg
subscriptions ({ state } as model) =
    let
        stateSub =
            case state of
                Home homeModel ->
                    home homeModel

                Setup setupModel ->
                    setup setupModel

                Play playModel ->
                    play playModel
    in
        Sub.batch
            [ stateSub
            , windowLoaded LoadingEnd
            ]



-- internals


home : HomeModel -> Sub Msg
home model =
    let
        landSub =
            model.landing
                |> Landing.subscriptions
                |> Sub.map LandingMsg
    in
        case model.websocket of
            Just model ->
                Sub.batch
                    [ websocket model
                    , landSub
                    ]

            Nothing ->
                landSub


setup : SetupModel -> Sub Msg
setup model =
    model.setup
        |> Setup.subscriptions
        |> Sub.map SetupMsg


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
