module Core.Models
    exposing
        ( Model(..)
        , HomeModel
        , PlayModel
        , initialModel
        , connect
        , login
        , logout
        , getConfig
        )

import Driver.Websocket.Models as Ws
import Game.Models as Game
import Game.Dummy as Game
import OS.Models as OS
import Landing.Models as Landing
import Core.Config as Config exposing (Config)


type Model
    = Home HomeModel
    | Play PlayModel


type alias HomeModel =
    { landing : Landing.Model
    , websocket : Maybe Ws.Model
    , config : Config
    , seed : Int
    }


type alias PlayModel =
    { game : Game.Model
    , os : OS.Model
    , websocket : Ws.Model
    , config : Config
    , seed : Int
    }


initialModel : Int -> Config -> Model
initialModel seed config =
    Home
        { landing = Landing.initialModel
        , websocket = Nothing
        , config = config
        , seed = seed
        }


connect : String -> String -> Model -> Model
connect token id model =
    case model of
        Home model ->
            let
                websocket =
                    Just (Ws.initialModel model.config.apiWsUrl token id)
            in
                Home { model | websocket = websocket }

        _ ->
            model


login : String -> Model -> Model
login token model =
    case model of
        Home { websocket, seed, config } ->
            case websocket of
                Just websocket ->
                    let
                        -- Replace this line with Game.initialModel
                        -- when starting to integrate game with the
                        -- server
                        game =
                            Game.dummy token config
                    in
                        Play
                            { game = game
                            , os = OS.initialModel
                            , websocket = websocket
                            , config = config
                            , seed = seed
                            }

                Nothing ->
                    model

        _ ->
            model


logout : Model -> Model
logout model =
    case model of
        Play { seed, config } ->
            initialModel seed config

        _ ->
            model


getConfig : Model -> Config
getConfig model =
    case model of
        Home m ->
            m.config

        Play m ->
            m.config
