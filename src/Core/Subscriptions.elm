module Core.Subscriptions exposing (subscriptions)

import Utils.Ports.OnLoad exposing (windowLoaded)
import Core.Error as Error
import Core.Messages exposing (..)
import Core.Models exposing (..)
import Core.Config exposing (..)
import Game.Data as GameD
import Game.Models as Game
import Game.Meta.Models as Meta
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

                Panic _ _ ->
                    Sub.none
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
setup ({ game, setup } as model) =
    let
        config =
            setupConfig
                game.account.id
                game.account.mainframe
                game.flags

        setupSub =
            Setup.subscriptions config setup
    in
        Sub.batch
            [ websocket model.websocket
            , setupSub
            ]


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
    case GameD.fromGateway game of
        Just data ->
            let
                activeServer =
                    case Game.getActiveServer game of
                        Just ( _, activeServer ) ->
                            activeServer

                        Nothing ->
                            "Player has no active Server"
                                |> Error.astralProj
                                |> uncurry Native.Panic.crash

                lastTick =
                    game
                        |> Game.getMeta
                        |> Meta.getLastTick

                account =
                    Game.getAccount game

                story =
                    Game.getStory game

                config =
                    osConfig account story lastTick activeServer
            in
                model
                    |> OS.subscriptions config data

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
